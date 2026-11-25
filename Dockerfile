# ==============================================================================
# Codyssey Mission 1: Custom Web Server Dockerfile
# Base Image: nginx:alpine (Lightweight NGINX + Alpine Linux)
# Custom Points:
#   1. Metadata labels (OCI standard)
#   2. System packages installation (curl for healthcheck & debugging, tzdata)
#   3. Environment variables (APP_ENV, APP_VERSION, SERVER_PORT, TZ)
#   4. Dynamic NGINX template configuration via /etc/nginx/templates (envsubst)
#   5. Static web application deployment & explicit file permissions (755/644)
#   6. Container HEALTHCHECK via /healthz endpoint
# ==============================================================================

FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="codyssey-workstation-web" \
      org.opencontainers.image.description="Codyssey Mission 1 Custom NGINX Web Server" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.authors="codyssey-developer"

# 1. 필수 유틸리티 패키지 설치 (헬스체크 및 타임존 설정용)
RUN apk add --no-cache curl tzdata

# 2. 기본 환경 변수 정의 (컨테이너 실행 시 -e 옵션으로 오버라이드 가능)
ENV APP_ENV=development \
    APP_VERSION=1.0.0 \
    SERVER_PORT=80 \
    TZ=Asia/Seoul

# 3. NGINX 동적 설정 템플릿 복사 (컨테이너 기동 시 envsubst가 자동 치환)
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template

# 4. 웹 서버 정적 콘텐츠 복사 및 권한 설정 (디렉토리 755, 파일 644)
WORKDIR /usr/share/nginx/html
RUN rm -rf /usr/share/nginx/html/*
COPY app/ /usr/share/nginx/html/
RUN chmod 755 /usr/share/nginx/html && \
    chmod 644 /usr/share/nginx/html/*

# 5. 컨테이너 노출 포트 명시
EXPOSE 80

# 6. 컨테이너 상태 자동 점검(HEALTHCHECK)
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -fsS http://localhost:${SERVER_PORT}/healthz || exit 1
