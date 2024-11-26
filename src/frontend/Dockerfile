# V1
FROM python:3.12-slim

LABEL version="0.1"

RUN groupadd -g 1001 app && \
    useradd -u 1001 -g app -m app

RUN mkdir /home/app/app /home/app/data /home/app/results

COPY requirements.txt /home/app/app
COPY streamlit_app.py /home/app/app
COPY helpers.py /home/app/app
COPY .streamlit /home/app/app

# Install pip requirements
WORKDIR /home/app/app
RUN python -m pip install -r requirements.txt

RUN chown -R app:app /home/app

EXPOSE 8501
# HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

USER app
WORKDIR /home/app/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["streamlit", "run", "/home/app/app/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]