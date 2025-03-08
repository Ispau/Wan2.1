# Imagen base con CUDA y PyTorch
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Configuración básica del sistema
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y ffmpeg git python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Instalar dependencias de Python
RUN pip3 install --no-cache-dir torch torchvision torchaudio gradio accelerate transformers \
    huggingface_hub easydict pickleshare flash-attn --pre --upgrade

# Configurar el directorio de trabajo
WORKDIR /app

# Clonar el repositorio (tu fork)
RUN git clone https://github.com/Ispau/Wan2.1.git && cd Wan2.1

# Instalar dependencias del repositorio
RUN pip3 install -r /app/Wan2.1/requirements.txt

# Descargar el modelo WAN2.1 Image-to-Video 480p desde Hugging Face
RUN huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P --local-dir /app/Wan2.1/models/wan_14B_480P

# Exponer el puerto para Gradio
EXPOSE 7860

# Comando para iniciar Gradio en RunPod
CMD ["python3", "/app/Wan2.1/gradio/i2v_14B_singleGPU.py", "--ckpt_dir_480p", "/app/Wan2.1/models/wan_14B_480P", "--share", "--server_name", "0.0.0.0", "--server_port", "7860"]
