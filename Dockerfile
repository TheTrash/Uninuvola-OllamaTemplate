FROM quay.io/uninuvola/base:main

# DO NOT EDIT USER VALUE
USER root

## -- ADD YOUR CODE HERE !! -- ##

# Update system and install dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg ca-certificates software-properties-common python3-pip git pciutils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Nvidia Container Toolkit environment variables to expose the GPU
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Ollama environment variables
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_MODELS=/home/jovyan/.ollama/models
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Ensure Ollama directory is pre-created and writeable by jovyan
RUN mkdir -p /home/jovyan/.ollama && chown -R jovyan:users /home/jovyan/.ollama

# Add automatic startup script to JupyterHub's hook directory
COPY start-ollama.sh /usr/local/bin/before-notebook.d/start-ollama.sh
RUN chmod +x /usr/local/bin/before-notebook.d/start-ollama.sh

# Install Python dependencies for RAG agent
RUN pip3 install --no-cache-dir \
    langchain \
    langchain-community \
    langchain-ollama \
    langchain-huggingface \
    chromadb \
    sentence-transformers \
    ollama

# Expose Ollama port
EXPOSE 11434

## --------------------------- ##

# DO NOT EDIT USER VALUE
USER jovyan
