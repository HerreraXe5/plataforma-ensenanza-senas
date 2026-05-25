from django.urls import path
from .views import obtener_modulos

urlpatterns = [
    path('modulos/', obtener_modulos, name='obtener_modulos'),
]