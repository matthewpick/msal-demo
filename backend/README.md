# Backend (FastAPI)

Simple FastAPI application to be deployed to AWS Lambda behind API Gateway + CloudFront.

## Endpoints
- `GET /health` returns status ok
- `GET /hello` returns greeting message

## Local Development

Dependencies are managed with `uv`. Install uv if you haven't already: https://docs.astral.sh/uv/

```bash
cd backend
uv sync          # creates .venv and installs dependencies from pyproject.toml
uv run start     # runs FastAPI dev server (uvicorn with reload)
```

Visit http://localhost:8000/health

## Environment Variables
- `FRONTEND_DOMAIN` (optional) used to configure CORS.

## Lambda Deployment (Manual Prototype)
Package code (simplistic example):
```bash
rm -rf build && mkdir build
uv export --no-hashes --frozen > requirements-export.txt
pip install --target build -r requirements-export.txt
cp -R app build/
cd build && zip -r ../lambda-package.zip . && cd ..
# Then upload lambda-package.zip to each Lambda or automate via Terraform later.
```

Note: Dependencies are managed in `pyproject.toml` with `uv`. For Lambda packaging, we export to a temporary requirements file, install to the build directory, then zip.

## Tests (placeholder)
Add tests under `tests/` using `pytest` and `httpx`.
