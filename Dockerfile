# Imagen oficial PyTorch con CUDA 11.8 (robusta y lista para usar)
FROM pytorch/pytorch:2.2.1-cuda11.8-cudnn8-devel

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar índices de paquetes primero, y luego instalar dependencias necesarias (muy preciso)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Actualizar pip a la última versión y setuptools primero (importante para dependencias posteriores)
RUN pip install --upgrade pip setuptools wheel

# Instalar dependencias PyTorch relacionadas con CUDA (ya optimizadas en la imagen base, por eso no se reinstalan)
RUN pip install --no-cache-dir \
    gradio \
    accelerate \
    transformers \
    huggingface_hub[easy] \
    easydict \
    pickleshare \
    flash-attn --pre --upgrade --no-cache-dir

# Configurar directorio claro de trabajo
WORKDIR /app

# Clonar tu fork del repositorio de Wan2.1
RUN git clone https://github.com/Ispau/Wan2.1.git /app/Wan2.1

# Instalar dependencias específicas del repositorio Wan2.1
RUN pip install --no-cache-dir -r /app/Wan2.1/requirements.txt

# Descargar modelo WAN2.1 Image-to-Video 480p (comprobado minuciosamente)
RUN mkdir -p /app/Wan2.1/models/wan_14B_480P && \
    huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P \
    --local-dir /app/Wan2.1/models/wan_14B_480P \
    --local-dir-use-symlinks False

# Exponer puerto específico
EXPOSE 7860

# Comando robusto para iniciar Gradio
CMD ["python3", "/app/Wan2.1/gradio/i2v_14B_singleGPU.py", \
     "--ckpt_dir_480p", "/app/Wan2.1/models/wan_14B_480P", \
     "--share", "--server_name", "0.0.0.0", "--server_port", "7860"]
