# 1️⃣ Base: PyTorch 2.2.1 con CUDA 11.8 y cuDNN 8 (compatible con H100/H200)
FROM pytorch/pytorch:2.2.1-cuda11.8-cudnn8-devel

# 2️⃣ Instalar dependencias del sistema necesarias (sin cosas extras)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ffmpeg libsm6 libxext6 libxrender1 libgl1 wget && \
    rm -rf /var/lib/apt/lists/*

# 3️⃣ Configurar directorio de trabajo
WORKDIR /app

# 4️⃣ Clonar Wan2.1 directamente en el contenedor
RUN git clone https://github.com/Wan-Video/Wan2.1.git /app/Wan2.1

# 5️⃣ Instalar PyTorch con CUDA 11.8 primero, evitando conflictos
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 6️⃣ Instalar librerías necesarias (EXCLUYENDO flash-attn)
RUN pip install --no-cache-dir \
    opencv-python diffusers transformers tokenizers accelerate tqdm imageio \
    easydict ftfy dashscope imageio-ffmpeg einops gradio numpy moviepy peft huggingface_hub

# 7️⃣ Descargar el modelo Wan2.1 480P desde Hugging Face
RUN huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P --local-dir /app/Wan2.1/models/wan_14B_480P

# 8️⃣ Instalar flash-attn solo después de haber instalado todo (evita errores de compilación)
RUN pip install --no-cache-dir flash-attn==2.3.0 --extra-index-url https://pypi.nvidia.com || \
    pip install --no-cache-dir flash-attn --no-build-isolation --force-reinstall

# 9️⃣ Exponer el puerto 7860 para Gradio
EXPOSE 7860

# 🔟 Comando de arranque (sin usar ENTRYPOINT para facilitar debugging)
CMD ["python", "Wan2.1/gradio/i2v_14B_singleGPU.py", "--ckpt_dir_480p", "/app/Wan2.1/models/wan_14B_480P"]
