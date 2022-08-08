FROM python:3.10-slim

RUN apt-get update

COPY requirements.txt .
RUN python3 -m pip install -r requirements.txt

ADD . /app
WORKDIR /app

RUN chmod +x entrypoint.sh

# Keep it running
ENTRYPOINT ["./entrypoint.sh"]
