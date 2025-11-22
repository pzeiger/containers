WORKDIR /home/ubuntu
RUN mkdir -p .jupyter && touch .jupyter/jupyter_lab_config.py

USER root
RUN << 'EOF'
pip install jupyterlab

mkdir -p /root/.jupyter
echo "c.ServerApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_lab_config.py
echo "c.ServerApp.port = 8888" >> /root/.jupyter/jupyter_lab_config.py
echo "c.ServerApp.allow_root = True" >> /root/.jupyter/jupyter_lab_config.py

echo "c.ServerApp.ip = '0.0.0.0'" >> /home/ubuntu/.jupyter/jupyter_lab_config.py
echo "c.ServerApp.port = 8888" >> /home/ubuntu/.jupyter/jupyter_lab_config.py
echo "c.ServerApp.allow_root = True" >> /home/ubuntu/.jupyter/jupyter_lab_config.py

EOF

CMD ["jupyter", "lab", "--no-browser"]
