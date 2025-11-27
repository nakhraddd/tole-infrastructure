#!/bin/bash
set -e

echo "--- Setting up Dummy Django Project ---"

# 1. Clean up old/empty files to ensure a clean slate
rm -rf tole_project manage.py requirements.txt

# 2. Create the project directory
mkdir -p tole_project

# 3. Create requirements.txt
echo "Creating requirements.txt..."
cat <<EOF > requirements.txt
django
gunicorn
mysqlclient
prometheus-client
EOF

# 4. Create the WSGI entry point (Critical for Gunicorn/Docker)
echo "Creating wsgi.py..."
cat <<EOF > tole_project/wsgi.py
import os
from django.core.wsgi import get_wsgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'tole_project.settings')
application = get_wsgi_application()
EOF

# 5. Create settings.py
echo "Creating settings.py..."
cat <<EOF > tole_project/settings.py
import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SECRET_KEY = 'insecure-dummy-key-for-testing'
DEBUG = True
ALLOWED_HOSTS = ['*']
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
ROOT_URLCONF = 'tole_project.urls'
WSGI_APPLICATION = 'tole_project.wsgi.application'
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}
STATIC_URL = '/static/'
EOF

# 6. Create urls.py
echo "Creating urls.py..."
cat <<EOF > tole_project/urls.py
from django.contrib import admin
from django.urls import path
from django.http import HttpResponse
import os

def home(request):
    return HttpResponse("<h1>TOLE Payment System is Running!</h1><p>Container ID: " + str(os.environ.get('HOSTNAME')) + "</p>")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', home),
]
EOF

# 7. Create empty __init__.py
touch tole_project/__init__.py

# 8. Create manage.py
echo "Creating manage.py..."
cat <<EOF > manage.py
#!/usr/bin/env python
import os
import sys

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'tole_project.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed?"
        ) from exc
    execute_from_command_line(sys.argv)

if __name__ == '__main__':
    main()
EOF

# Make manage.py executable
chmod +x manage.py

echo "--- Project Setup Complete ---"
