#!/usr/bin/env python3
"""
Container Builder Script
Automates building Docker/Apptainer containers for different clusters
"""
from code.containerbuilder import ContainerBuilder
import argparse
import sys
from pathlib import Path


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Build Docker/Apptainer containers from modular configs',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --config cluster_alpha --dry-run
  %(prog)s --config cluster_alpha --build
  %(prog)s --list-configs
        """
    )
    
    parser.add_argument(
        '--config', '-c',
        help='Name of machine configuration (without .yaml extension)'
    )
    parser.add_argument(
        '--build', '-b',
        action='store_true',
        help='Build the container (default is dry-run)'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Generate definition file only, do not build'
    )
    parser.add_argument(
        '--common-dir',
        type=Path,
        default=Path('common'),
        help='Directory containing module definitions (default: common/)'
    )
    parser.add_argument(
        '--machines-dir',
        type=Path,
        default=Path('machines'),
        help='Directory containing machine configs (default: machines/)'
    )
    parser.add_argument(
        '--output-dir',
        type=Path,
        default=Path('build'),
        help='Output directory for generated files (default: build/)'
    )
    parser.add_argument(
        '--list-configs',
        action='store_true',
        help='List available machine configurations'
    )
    
    args = parser.parse_args()
    
    # Initialize builder
    builder = ContainerBuilder(
        common_dir=args.common_dir,
        machines_dir=args.machines_dir,
        output_dir=args.output_dir
    )
    
    # List configs if requested
    if args.list_configs:
        print("Available machine configurations:")
        if args.machines_dir.exists():
            configs = sorted(args.machines_dir.glob('*.yaml'))
            for config in configs:
                print(f"  - {config.stem}")
        else:
            print(f"  No configs found in {args.machines_dir}")
        return 0
    
    # Build container
    if not args.config:
        parser.print_help()
        return 1
    
    dry_run = args.dry_run or not args.build
    success = builder.build_container(args.config, dry_run=dry_run)
    
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())


