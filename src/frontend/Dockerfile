###############################################
# Base stage (shared between build and final) #
###############################################

FROM python:3.12-slim AS base

###############
# Build stage #
###############

FROM base AS builder

## Install and configure UV, see https://docs.astral.sh/uv/ for more information

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/app/app/.venv

WORKDIR /app/app/

COPY uv.lock pyproject.toml /app/app/
RUN uv sync \
    --frozen \
    --no-dev \
    --no-install-workspace \
    --no-editable \
    --all-packages

COPY *.py .streamlit /app/app/

###############
# Final image #
###############

FROM base

LABEL version="0.2"

RUN groupadd -r app
RUN useradd -r -d /app -g app -N app
RUN mkdir /app/ /app/data/ /app/results/

COPY --from=builder --chown=app:app /app /app
RUN chown -R app:app /app
WORKDIR /app/app
USER app

EXPOSE 8501

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/app/app/.venv/bin/streamlit", "run", "/app/app/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]