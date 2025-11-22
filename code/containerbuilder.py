import os
import yaml
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime


class ContainerBuilder:
    """Main class for building containers from modular configurations"""
    
    def __init__(self, common_dir: Path, machines_dir: Path, output_dir: Path, build_threads: int=None):
        """
        Initialize the container builder
        
        Args:
            common_dir: Directory containing module definition files
            machines_dir: Directory containing machine YAML configs
            output_dir: Directory for generated Dockerfiles/def files
        """
        self.common_dir = Path(common_dir)
        self.machines_dir = Path(machines_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        if build_threads is None:
            self.build_threads = os.cpu_count() or 4
        else:
            self.build_threads = max(1, int(build_threads))
        
    def load_machine_config(self, config_name: str) -> Dict[str, Any]:
        """Load machine configuration from YAML file"""
        config_path = self.machines_dir / f"{config_name}.yaml"
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)
        return config
    
    def load_module(self, module_name: str) -> str:
        """Load a module definition file"""
        module_path = self.common_dir / f"{module_name}.dockerfile"
        if not module_path.exists():
            raise FileNotFoundError(f"Module not found: {module_path}")
        
        with open(module_path, 'r') as f:
            return f.read()

    def substitute_variables(self, content: str, variables: Dict[str, Any]) -> str:
        """Substitute variables in module content"""
        for key, value in variables.items():
            placeholder = "{" + key + "}"
            content = content.replace(placeholder, str(value))
        return content

    def get_all_install_vars(self, config: Dict[str, Any], module: Dict[str, Any]) -> Dict[str, Any]:
        install_vars = {}
        # Global builder settings (lowest priority)
        install_vars['build_threads'] = str(self.build_threads)
        # Config-level install_vars
        if 'install_vars' in config:
            install_vars.update(config['install_vars'])
        # Module-level install_vars (highest priority)
        if 'install_vars' in module:
            install_vars.update(module['install_vars'])
        # Module metadata
        install_vars['version'] = module.get('version', 'latest')
        install_vars['name'] = module.get('name', 'unknown')
        return install_vars

    
    def generate_dockerfile(self, config: Dict[str, Any]) -> str:
        """Generate complete Dockerfile from config"""
        lines = []
        
        # Add header
        lines.append(f"# Generated Dockerfile for {config.get('machine_name', 'unknown')}")
        lines.append(f"# Generated on: {datetime.now().isoformat()}")
        lines.append(f"# Container type: {config.get('container_type', 'docker')}")
        lines.append("# syntax=docker/dockerfile:1-labs")
        lines.append("")
        
        # Base image
        base_image = config.get('base_image', 'ubuntu:22.04')
        lines.append(f"FROM {base_image}")
        lines.append("")
        
        # Build arguments
        if 'build_args' in config:
            for key, value in config['build_args'].items():
                lines.append(f"ARG {key.upper()}={value}")
            lines.append("")
        
        # Environment variables
        if 'environment_vars' in config:
            try:
                for key, value in config['environment_vars'].items():
                    lines.append(f"ENV {key}={value}")
                lines.append("")
            except AttributeError:    # no keys in config
                pass
        
        # Process modules
        if 'modules' in config:
            for module in config['modules']:
                if not module.get('enabled', True):
                    continue
                
                module_name = module['name']
                print(f"  Loading module: {module_name}")
                
                # Load module content
                try:
                    module_content = self.load_module(module_name)
                    install_vars = self.get_all_install_vars(config, module)
                    module_content = self.substitute_variables(module_content, install_vars)

                    if 'install_vars' in module:
                        install_vars.update(module['install_vars'])

                    module_content = self.substitute_variables(module_content, install_vars)
                    
                    lines.append(f"# Module: {module_name} (version: {install_vars['version']})")
                    lines.append(module_content)
                    lines.append("")
                    
                    # We always switch to an unprivileged user and cd to their home
                    lines.append("USER ubuntu")
                    lines.append(f"WORKDIR {config['environment_vars']['workdir']}")
                    
                except FileNotFoundError as e:
                    print(f"  Warning: {e}")
                    continue
        
        # Final cleanup
        lines.append("# Final cleanup")
        lines.append("USER root")
        lines.append("RUN apt-get clean && rm -rf /var/lib/apt/lists/* && pip cache purge && rm -r /tmp/*")
        lines.append("USER ubuntu")
        lines.append(f"WORKDIR {config['environment_vars']['workdir']}")
        lines.append("")
        
        return "\n".join(lines)
    
    def generate_apptainer_def(self, config: Dict[str, Any]) -> str:
        """Generate Apptainer definition file from config"""
        lines = []
        
        # Header
        lines.append(f"Bootstrap: docker")
        lines.append(f"From: {config.get('base_image', 'ubuntu:22.04')}")
        lines.append("")
        
        # Post section
        lines.append("%post")
        lines.append(f"    # Generated for {config.get('machine_name', 'unknown')}")
        lines.append(f"    # Generated on: {datetime.now().isoformat()}")
        lines.append("")
        
        # Process modules
        if 'modules' in config:
            for module in config['modules']:
                if not module.get('enabled', True):
                    continue
                
                module_name = module['name']
                print(f"  Loading module: {module_name}")
                
                try:
                    module_content = self.load_module(module_name)
                    install_vars = self.get_all_variables(config, module)
                    module_content = self.substitute_variables(module_content, install_vars)

                    if 'install_vars' in module:
                        install_vars.update(module['install_vars'])
                    
                    module_content = self.substitute_variables(module_content, install_vars)
                    
                    # Convert Docker RUN commands to Apptainer format
                    processed_lines = []
                    for line in module_content.split('\n'):
                        if line.strip().startswith('RUN '):
                            processed_lines.append('    ' + line.strip()[4:])
                        elif line.strip().startswith('#'):
                            processed_lines.append('    ' + line.strip())
                        elif line.strip():
                            processed_lines.append('    ' + line.strip())
                    
                    lines.append(f"    # Module: {module_name}")
                    lines.extend(processed_lines)
                    lines.append("")

                    
                except FileNotFoundError as e:
                    print(f"  Warning: {e}")
                    continue
        
        # Environment section
        if 'environment_vars' in config:
            lines.append("")
            lines.append("%environment")
            try:
                for key, value in config['environment_vars'].items():
                    lines.append(f"    export {key}={value}")
            except AttributeError:    # no keys in config
                pass
        return "\n".join(lines)
    
    def build_container(self, config_name: str, dry_run: bool = False) -> bool:
        """Build container from configuration"""
        print(f"\nBuilding container for: {config_name}")
        print("=" * 60)
        
        # Load configuration
        config = self.load_machine_config(config_name)
        container_type = config.get('container_type', 'docker').lower()
        machine_name = config.get('machine_name', config_name)
        
        # Generate appropriate definition file
        if container_type == 'apptainer':
            definition = self.generate_apptainer_def(config)
            output_file = self.output_dir / f"{machine_name}.def"
            image_name = f"{machine_name}.sif"
        else:
            definition = self.generate_dockerfile(config)
            output_file = self.output_dir / f"Dockerfile.{machine_name}"
            image_name = f"{machine_name}:latest"
        
        # Write definition file
        print(f"\nWriting definition file to: {output_file}")
        with open(output_file, 'w') as f:
            f.write(definition)
        
        if dry_run:
            print("\nDry run mode - skipping actual build")
            print(f"Definition file saved to: {output_file}")
            return True
        
        # Build container
        print(f"\nBuilding {container_type} container...")
        try:
            if container_type == 'apptainer':
                cmd = [
                    'apptainer', 'build',
                    str(self.output_dir / image_name),
                    str(output_file)
                ]
            else:
                cmd = [
                    'docker', 'build',
                    '-t', image_name,
                    '-f', str(output_file),
                    '.'
                ]
            
            print(f"Running command: {' '.join(cmd)}")
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print(result.stdout)
            print(f"\nSuccessfully built: {image_name}")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"\nError building container: {e}")
            print(e.stderr)
            return False
        except FileNotFoundError:
            print(f"\nError: {container_type} command not found. Is it installed?")
            return False


