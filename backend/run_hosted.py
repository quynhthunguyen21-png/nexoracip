"""Hosting entry point. Use host-provided variables, never read/upload a local .env."""
import os


def main():
    if os.environ.get('APP_ENV') != 'demo':
        raise ValueError('Set APP_ENV=demo for password-protected hosting')
    port = int(os.environ.get('PORT', '8000'))
    if not 1 <= port <= 65535:
        raise ValueError('Invalid hosting port')
    import uvicorn
    uvicorn.run('backend.app.main:app', host='0.0.0.0', port=port, workers=1, proxy_headers=True, forwarded_allow_ips='*')


if __name__ == '__main__':
    main()
