FROM node:24.20.0-alpine AS frontend
WORKDIR /build/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM python:3.12.15-slim
WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
COPY backend/requirements.hosted.lock /app/backend/requirements.hosted.lock
RUN pip install --no-cache-dir --require-hashes -r backend/requirements.hosted.lock
COPY backend/ /app/backend/
COPY data/intake/2026-10-21-sos/intake.json /app/data/intake/2026-10-21-sos/intake.json
COPY --from=frontend /build/frontend/dist /app/frontend/dist
EXPOSE 8000
CMD ["python", "-m", "backend.run_hosted"]
