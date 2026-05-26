from rest_framework import viewsets, permissions, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth.models import User
from .models import Modulo, Sena, SenaFavorita, ResultadoQuiz
from .serializers import ModuloSerializer, SenaSerializer, RegistroSerializer, SenaFavoritaSerializer, ResultadoQuizSerializer, PerfilSerializer

class EsAdminOpcionesLectura(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True 
        return request.user and request.user.is_staff

class ModuloViewSet(viewsets.ModelViewSet):
    queryset = Modulo.objects.all().order_by('orden')
    serializer_class = ModuloSerializer
    permission_classes = [EsAdminOpcionesLectura]

class SenaViewSet(viewsets.ModelViewSet):
    queryset = Sena.objects.all()
    serializer_class = SenaSerializer
    permission_classes = [EsAdminOpcionesLectura]

class RegistroView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegistroSerializer

class FavoritasViewSet(viewsets.ModelViewSet):
    serializer_class = SenaFavoritaSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return SenaFavorita.objects.filter(usuario=self.request.user).order_by('-fecha_agregada')

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

class ResultadoQuizViewSet(viewsets.ModelViewSet):
    serializer_class = ResultadoQuizSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return ResultadoQuiz.objects.filter(usuario=self.request.user).order_by('-fecha')

    def perform_create(self, serializer):
        serializer.save(usuario=self.request.user)

# --- NUEVO: VISTA DE PERFIL ---
class PerfilUsuarioView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = PerfilSerializer(request.user)
        return Response(serializer.data)