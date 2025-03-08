FROM pytorch/pytorch:2.2.1-cuda11.8-cudnn8-devel

# Configuración básica
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias adicionales del sistema
RUN apt-get update && apt-get install -y ffmpeg git ninja && \
    rm -rf /var/lib/apt/lists/*

# Instalar dependencias Python adicionales (aprovechando la instalación previa de PyTorch)
RUN pip install --upgrade pip setuptools wheel && \
    pip install gradio accelerate transformers huggingface_hub easydict pickleshare && \
    pip install flash-attn --pre --upgrade --no-cache-dir

# Configurar el directorio de trabajo
WORKDIR /app

# Clonar tu repositorio directamente
RUN git clone https://github.com/Ispau/Wan2.1.git /app/Wan2.1

# Instalar dependencias del repositorio
RUN pip install -r /app/Wan2.1/requirements.txt

# Descargar modelo Image-to-Video 480p desde Hugging Face (solo si no existe)
RUN test -d /app/Wan2.1/models/wan_14B_480P || huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P --local-dir /app/Wan2.1/models/wan_14B_480P --local-dir-use-symlinks False

# Exponer el puerto de Gradio
EXPOSE 7860

# Lanzar Gradio automáticamente
CMD ["python3", "/app/Wan2.1/gradio/i2v_14B_singleGPU.py", "--ckpt_dir_480p", "/app/Wan2.1/models/wan_14B_480P", "--share", "--server_name", "0.0.0.0", "--server_port", "7860"]
