# SignuDoc on Railway: upstream NYLLON-SOFTWARE/SignuDoc (MIT) built from source at a pinned commit, code unmodified.
# Railway layer: listens on 8080, applies DB migrations on every boot, keeps PDFs on the /data volume
# and calls the daily retention cleanup from inside the container.
ARG SIGNUDOC_COMMIT=24ecc5d488d4c021affc7f22d4632c02e76cc387

FROM node:24-bookworm-slim AS builder
ARG SIGNUDOC_COMMIT
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/NYLLON-SOFTWARE/SignuDoc /app && cd /app && git checkout ${SIGNUDOC_COMMIT}
WORKDIR /app
RUN npm ci
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run build

FROM node:24-bookworm-slim
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/signudoc"
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app /app
COPY railway/start.sh /railway-start.sh
RUN chmod +x /railway-start.sh && mkdir -p /data/storage
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    STORAGE_DRIVER=local \
    STORAGE_LOCAL_DIR=/data/storage \
    HOSTNAME=::
EXPOSE 8080
CMD ["/railway-start.sh"]
