# 1. Imagen base con PyTorch 2.2.1, CUDA 11.8 y cuDNN 8 (compatible con GPU H100/H200)
FROM pytorch/pytorch:2.2.1-cuda11.8-cudnn8-devel

# 2. Instalación de dependencias del sistema (git, ffmpeg, libs para OpenCV) 
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ffmpeg libsm6 libxext6 libxrender1 libgl1 && \
    rm -rf /var/lib/apt/lists/*

# 3. Copiar o clonar el código fuente de Wan2.1 en el contenedor
# (Clonamos directamente desde el repositorio oficial de Wan2.1)
RUN git clone https://github.com/Wan-Video/Wan2.1.git /app/Wan2.1

# Establecer el directorio de trabajo
WORKDIR /app/Wan2.1

# 4. Instalación de dependencias de Python (PyTorch ya incluido en la imagen base)
#    Incluye Diffusers, Transformers, Tokenizers, Accelerate, TQDM, ImageIO, Gradio, etc.
RUN pip install --no-cache-dir \
    opencv-python>=4.9.0.80 \
    diffusers>=0.31.0 transformers>=4.49.0 tokenizers>=0.20.3 accelerate>=1.1.1 \
    tqdm imageio easydict ftfy dashscope imageio-ffmpeg einops \
    gradio>=5.0.0 numpy>=1.23.5,<2 \
    moviepy==1.0.3 mmgp==3.2.3 peft==0.14.0 && \
    pip install --no-cache-dir flash-attn==2.7.2.post1 huggingface_hub[cli]

# 5. Descarga automática del modelo Wan2.1 I2V 14B 480P desde Hugging Face
#    (Se almacena en ./Wan2.1-I2V-14B-480P dentro del contenedor)
RUN huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P --local-dir Wan2.1-I2V-14B-480P && \
    rm -rf /root/.cache/huggingface

# 6. Exponer el puerto 7860 para la interfaz Gradio
EXPOSE 7860

# 7. Comando de arranque: lanza el servidor Gradio con el modelo descargado
CMD ["python", "gradio/i2v_14B_singleGPU.py", "--ckpt_dir_480p", "./Wan2.1-I2V-14B-480P"]
