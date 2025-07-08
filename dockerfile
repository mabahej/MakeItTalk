FROM ubuntu:20.04

# 1. System deps
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      python3.6 python3-pip python3-dev \
      ffmpeg wget git \
      dpkg-dev apt-transport-https gnupg2 && \
    rm -rf /var/lib/apt/lists/*
# 2. Set Python symlink
RUN ln -s /usr/bin/python3.6 /usr/bin/python

# 3. Clone & install the repo
WORKDIR /app
COPY . /app


# 4. Copy our wrapper in
COPY app.py /app/MakeItTalk/app.py

# 5. Install Python requirements
COPY requirements.txt /app/MakeItTalk/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install flask gsutil google-cloud-storage

# 6. Copy pre-trained models into the image
#    (assumes you’ve placed them alongside your Dockerfile)
COPY examples/ckpt /app/MakeItTalk/examples/ckpt
COPY examples/dump /app/MakeItTalk/examples/dump

EXPOSE 8080
CMD ["python", "app.py"]
