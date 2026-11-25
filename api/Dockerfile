FROM python:3.12-alpine

LABEL org.opencontainers.image.title="codyssey-companion-api" \
      org.opencontainers.image.description="Codyssey Mission 1 Companion JSON API Server"

WORKDIR /app
COPY server.py /app/server.py
RUN chmod 755 /app/server.py

ENV APP_ENV=compose-staging \
    API_PORT=5000 \
    DATA_FILE=/data/requests.log

EXPOSE 5000

CMD ["python3", "/app/server.py"]
