# Imagen base optimizada con CUDA 11.8
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Evita prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependencias del sistema esenciales en un solo paso y limpia inmediatamente
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    ninja-build && \
    rm -rf /var/lib/apt/lists/*

# Actualiza pip y setuptools primero para evitar incompatibilidades
RUN python3 -m pip install --upgrade pip setuptools wheel

# Instala PyTorch (optimizado para CUDA 11.8)
RUN pip3 install --no-cache-dir torch torchvision torchaudio \
    --extra-index-url https://download.pytorch.org/whl/cu118

# Instala dependencias adicionales de Python
RUN pip3 install --no-cache-dir \
    gradio \
    accelerate \
    transformers \
    huggingface_hub[easy] \
    easydict \
    pickleshare \
    flash-attn --pre --upgrade --no-build-isolation

# Define el directorio de trabajo claramente
WORKDIR /app

# Clona el repositorio directamente en el directorio correcto
RUN git clone https://github.com/Ispau/Wan2.1.git /app/Wan2.1

# Instala las dependencias del repositorio clonado
RUN pip3 install --no-cache-dir -r /app/Wan2.1/requirements.txt

# Descarga el modelo WAN2.1 Image-to-Video 480p sólo si no existe ya
RUN mkdir -p /app/Wan2.1/models/wan_14B_480P && \
    huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P \
    --local-dir /app/Wan2.1/models/wan_14B_480P --local-dir-use-symlinks False

# Puerto que expondrá la aplicación Gradio
EXPOSE 7860

# Comando optimizado y explícito para iniciar la aplicación Gradio
CMD ["python3", "/app/Wan2.1/gradio/i2v_14B_singleGPU.py", \
     "--ckpt_dir_480p", "/app/Wan2.1/models/wan_14B_480P", \
     "--share", "--server_name", "0.0.0.0", "--server_port", "7860"]
