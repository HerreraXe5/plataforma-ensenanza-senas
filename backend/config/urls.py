from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')), # Las rutas del CRUD
    path('api/login/', TokenObtainPairView.as_view(), name='login'), # La ruta para el Login
]