FROM node:24.20.0-alpine AS frontend
WORKDIR /build
COPY nexora-source.tar.gz /tmp/nexora-source.tar.gz
RUN echo "ded5f7843fa7fc082bb29befc7a51d3a24271deab8c68265731a18f83ca62e1b  /tmp/nexora-source.tar.gz" | sha256sum -c - && tar -xzf /tmp/nexora-source.tar.gz -C /build
WORKDIR /build/frontend
RUN npm ci && npm run build

FROM python:3.12.15-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY --from=frontend /build/backend/ /app/backend/
RUN pip install --no-cache-dir --require-hashes -r backend/requirements.hosted.lock
COPY --from=frontend /build/data/intake/2026-10-21-sos/intake.json /app/data/intake/2026-10-21-sos/intake.json
COPY --from=frontend /build/frontend/dist /app/frontend/dist
EXPOSE 8000
CMD ["python", "-m", "backend.run_hosted"]
