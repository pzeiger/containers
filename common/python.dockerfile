# Copy uv into image
USER ubuntu
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /home/ubuntu/bin/
ENV PATH="/home/ubuntu/bin:$PATH"

ENV VIRTUAL_ENV=/opt/venv
RUN uv venv --python {version}
RUN uv pip install --no-cache-dir --upgrade pip setuptools wheel
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

