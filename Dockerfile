FROM node:24.20.0-alpine AS frontend
WORKDIR /build
COPY nexora-source.tar.gz /tmp/nexora-source.tar.gz
RUN echo "98299d4974642e339f1c3948ea1689cd2f6537d8d4c29a5db85046ea0698f03b  /tmp/nexora-source.tar.gz" | sha256sum -c - && tar -xzf /tmp/nexora-source.tar.gz -C /build
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
