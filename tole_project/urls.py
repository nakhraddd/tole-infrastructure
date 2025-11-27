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
