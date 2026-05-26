from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Modulo, Sena, SenaFavorita, Pregunta, ResultadoQuiz

class SenaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sena
        fields = '__all__'

class PreguntaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Pregunta
        fields = '__all__'

class ModuloSerializer(serializers.ModelSerializer):
    senas = SenaSerializer(many=True, read_only=True) 
    preguntas = PreguntaSerializer(many=True, read_only=True)
    
    class Meta:
        model = Modulo
        fields = ['id', 'titulo', 'descripcion', 'orden', 'senas', 'preguntas']

class SenaFavoritaSerializer(serializers.ModelSerializer):
    sena_detalle = SenaSerializer(source='sena', read_only=True)

    class Meta:
        model = SenaFavorita
        fields = ['id', 'sena', 'sena_detalle', 'fecha_agregada']
        read_only_fields = ['usuario']

class ResultadoQuizSerializer(serializers.ModelSerializer):
    modulo_titulo = serializers.CharField(source='modulo.titulo', read_only=True)

    class Meta:
        model = ResultadoQuiz
        fields = ['id', 'modulo', 'modulo_titulo', 'puntaje', 'fecha']
        read_only_fields = ['usuario']

class RegistroSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'email', 'password')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        return user

# --- NUEVO: SERIALIZADOR DE PERFIL ---
class PerfilSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email', 'is_staff']