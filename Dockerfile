# Wan2.1 - Dockerfile para RunPod Serverless (CUDA 12.4)

# 1️⃣ Base: PyTorch 2.4.0 con CUDA 12.4 y Ubuntu 22.04
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# 2️⃣ Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git cmake libgl1-mesa-glx libglib2.0-0 libsm6 libxext6 && \
    rm -rf /var/lib/apt/lists/*

# 3️⃣ Configurar directorio de trabajo
WORKDIR /app

# 4️⃣ Clonar el repositorio Wan2.1
RUN git clone https://github.com/Ispau/Wan2.1.git /app/Wan2.1
WORKDIR /app/Wan2.1

# 5️⃣ Instalar PyTorch y librerías necesarias (CUDA 12.4)
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 && \
    pip install --no-cache-dir opencv-python diffusers transformers tokenizers accelerate tqdm imageio easydict \
    ftfy dashscope imageio-ffmpeg gradio 'numpy>=1.23.5,<2' pickleshare

# 6️⃣ Instalar flash-attn optimizado para CUDA 12.4
RUN pip install --no-cache-dir flash-attn==2.7.2.post1 --extra-index-url https://pypi.nvidia.com

# 7️⃣ Descargar el modelo Wan2.1 480P desde Hugging Face
RUN pip install -U "huggingface_hub[cli]" && \
    huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P --local-dir /app/Wan2.1/models/wan_14B_480P

# 8️⃣ Exponer el puerto 7860 (opcional, pero no necesario en serverless)
EXPOSE 7860

# 9️⃣ Comando de arranque sin `--share` ni `--server`
CMD ["python", "gradio/i2v_14B_singleGPU.py", "--ckpt_dir_480p", "./models/wan_14B_480P"]
