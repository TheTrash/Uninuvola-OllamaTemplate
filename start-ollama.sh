#!/bin/bash

# Ensure Ollama is installed
if ! command -v ollama >/dev/null 2>&1; then
    echo "Ollama is not installed or not in PATH."
    exit 0
fi

# Export environment variables for the current shell and subsequent processes
export OLLAMA_HOST=0.0.0.0
export OLLAMA_MODELS=/home/jovyan/.ollama/models
export LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

echo "Starting Ollama server in the background..."

if [ "$(id -u)" -eq 0 ]; then
    # Running as root, start Ollama as jovyan
    if id "jovyan" >/dev/null 2>&1; then
        # Ensure the log file directory is writeable by jovyan
        touch /home/jovyan/ollama.log
        chown jovyan:users /home/jovyan/ollama.log
        # Create models directory and set permissions
        mkdir -p /home/jovyan/.ollama/models
        chown -R jovyan:users /home/jovyan/.ollama
        # Run ollama serve as jovyan
        runuser -u jovyan -- nohup ollama serve > /home/jovyan/ollama.log 2>&1 &
    else
        # No jovyan user, run as root (fallback)
        mkdir -p /root/.ollama/models
        nohup ollama serve > /root/ollama.log 2>&1 &
    fi
else
    # Running as non-root user (e.g. jovyan)
    mkdir -p /home/jovyan/.ollama/models
    nohup ollama serve > /home/jovyan/ollama.log 2>&1 &
fi

echo "Ollama server startup script completed."
