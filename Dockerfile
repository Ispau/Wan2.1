FROM pytorch/pytorch:2.2.1-cuda11.8-cudnn8-devel

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias esenciales del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Actualizar pip, setuptools y wheel
RUN pip install --upgrade pip setuptools wheel

# Instalar dependencias adicionales de Python SIN FLASH-ATTN
RUN pip install --no-cache-dir \
    gradio \
    accelerate \
    transformers \
    huggingface_hub[easy] \
    easydict \
    pickleshare \
    imageio \
    ftfy \
    diffusers \
    einops \
    flash-attn

# Configurar directorio de trabajo
WORKDIR /app

# Clonar tu fork del repositorio Wan2.1
RUN git clone https://github.com/Ispau/Wan2.1.git /app/Wan2.1

# Instalar dependencias específicas del repositorio Wan2.1
RUN pip install --no-cache-dir -r /app/Wan2.1/requirements.txt

# Descargar modelo WAN2.1 Image-to-Video 480p desde Hugging Face
RUN mkdir -p /app/Wan2.1/models/wan_14B_480P && \
    huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P \
    --local-dir /app/Wan2.1/models/wan_14B_480P \
    --local-dir-use-symlinks False

# Exponer puerto específico para Gradio
EXPOSE 7860

# Comando robusto para iniciar Gradio sin errores
CMD ["python3", "/app/Wan2.1/gradio/i2v_14B_singleGPU.py", \
     "--ckpt_dir_480p", "/app/Wan2.1/models/wan_14B_480P", \
     "--share", "--server_name", "0.0.0.0", "--server_port", "7860"]
