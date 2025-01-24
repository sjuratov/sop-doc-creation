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
    UV_PROJECT_ENVIRONMENT=/home/app/app/.venv

WORKDIR /home/app/app/

COPY uv.lock pyproject.toml /home/app/app/
RUN uv sync \
    --frozen \
    --no-dev \
    --no-install-workspace \
    --no-editable \
    --all-packages

COPY *.py .streamlit /home/app/app/

###############
# Final image #
###############

FROM base

LABEL version="0.2"

RUN groupadd -r app
RUN useradd -r -d /home/app -g app -N app
RUN mkdir /home/app/ /home/app/data/ /home/app/results/

COPY --from=builder --chown=app:app /home/app /home/app
RUN chown -R app:app /home/app
WORKDIR /home/app/app
USER app

EXPOSE 8501

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/home/app/app/.venv/bin/streamlit", "run", "/home/app/app/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]