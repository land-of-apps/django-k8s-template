FROM python:3.9-slim-buster

ENV PYTHONUNBUFFERED=1

WORKDIR /usr/src/app

COPY ./oscar/ .

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install -e .[test]
RUN pip install -r requirements.txt

RUN make sandbox

EXPOSE 8000