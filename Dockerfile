FROM nvidia/cuda:12.4.1-base-ubuntu22.04

RUN apt-get update -y && apt-get install -y \
   python3-pip python3-dev git build-essential

ARG PUID=1000
ARG PGID=1000

RUN groupadd -g "${PGID}" appuser \
&& useradd -m -s /bin/sh -u "${PUID}" -g "${PGID}" appuser

WORKDIR /workspace

# Install sd-scripts dependencies
RUN git clone -b sd3 https://github.com/kohya-ss/sd-scripts /tmp/sd-scripts \
&& cd /tmp/sd-scripts \
&& pip install --no-cache-dir -r requirements.txt \
&& cd / \
&& rm -rf /tmp/sd-scripts

# Install your app dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt \
&& pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 \
&& pip install --upgrade --force-reinstall triton==2.1.0

RUN chown -R appuser:appuser /workspace
USER appuser

EXPOSE 7860
ENV GRADIO_SERVER_NAME="0.0.0.0"

CMD ["python3", "app.py"]