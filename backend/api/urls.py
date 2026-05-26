from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ModuloViewSet, SenaViewSet, RegistroView, FavoritasViewSet, ResultadoQuizViewSet, PerfilUsuarioView

router = DefaultRouter()
router.register(r'modulos', ModuloViewSet)
router.register(r'senas', SenaViewSet)
router.register(r'favoritas', FavoritasViewSet, basename='favoritas')
router.register(r'historial', ResultadoQuizViewSet, basename='historial')

urlpatterns = [
    path('', include(router.urls)),
    path('registro/', RegistroView.as_view(), name='registro'),
    path('perfil/', PerfilUsuarioView.as_view(), name='perfil'), # Nueva ruta
]