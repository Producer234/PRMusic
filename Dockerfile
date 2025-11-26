FROM nikolaik/python-nodejs:python3.10-nodejs19

# Fix Debian archive sources
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i '/security.debian.org/d' /etc/apt/sources.list

# Install required system libraries for OpenCV and ffmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    build-essential \
    wget \
    curl \
    python3-dev \
    git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure ffmpeg is in PATH
ENV PATH="/usr/bin:${PATH}"

# Set working directory
WORKDIR /app/

# Copy project files
COPY . /app/

# Upgrade pip and install Python build tools
RUN pip3 install --upgrade pip setuptools wheel

# Pre-cache OpenCV and heavy wheels
RUN pip3 download --no-deps --dest /tmp/wheels opencv-python numpy pillow

# Install Python dependencies using cached wheels first
RUN pip3 install --no-cache-dir --find-links=/tmp/wheels -r requirements.txt

# Clean wheel cache to reduce image size
RUN rm -rf /tmp/wheels

# Start bot
CMD ["bash", "start"]