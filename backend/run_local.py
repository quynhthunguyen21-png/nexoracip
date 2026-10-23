"""Explicit local launcher: read the root .env as data, never as shell code."""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ALLOWED = {"DATABASE_URL", "TEST_DATABASE_URL", "APP_ENV", "AI_MODE", "OPENAI_API_KEY", "OPENAI_MODEL", "GEMINI_API_KEY", "GEMINI_MODEL", "AI_DATA_SHARING_APPROVED", "JIRA_EMAIL", "JIRA_API_TOKEN", "JIRA_TOKEN_MODE", "JIRA_CLOUD_ID", "JIRA_ALLOWED_PROJECTS", "JIRA_WRITE_ENABLED", "DEMO_USERNAME", "DEMO_PASSWORD", "DEMO_PUBLIC_URL", "DEMO_STORAGE_DIR"}


def load_private_env(path: Path, environ=None):
    target = os.environ if environ is None else environ
    if not path.is_file():
        return
    parsed = {}
    for number, line in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        key, sep, value = line.partition("=")
        key, value = key.strip(), value.strip()
        if not sep or key not in ALLOWED:
            raise ValueError(f"Invalid or unsupported configuration at line {number}; values are not displayed.")
        if value.startswith(("'", '"')):
            if len(value) < 2 or value[-1] != value[0]:
                raise ValueError(f"Unclosed configuration quote at line {number}.")
            value = value[1:-1]
        if key in parsed:
            raise ValueError(f"Duplicate configuration name at line {number}.")
        parsed[key] = value
    for key, value in parsed.items():
        target.setdefault(key, value)


def main():
    load_private_env(ROOT / ".env")
    import uvicorn
    uvicorn.run("backend.app.main:app", host="127.0.0.1", port=8000, reload=False)


if __name__ == "__main__":
    main()
