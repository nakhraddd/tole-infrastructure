FROM python:3.10-slim-bookworm

# Fixed warnings by adding '='
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Update: Switched to 'default-libmysqlclient-dev' which is more compatible
# and pinned base image to 'bookworm' to avoid 'package not found' errors.
RUN apt-get update \
    && apt-get install -y build-essential default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/

RUN useradd -ms /bin/bash tole
RUN chown -R tole:tole /app
USER tole

EXPOSE 8000

CMD ["gunicorn", "--workers=3", "--bind", "0.0.0.0:8000", "tole_project.wsgi:application"]
