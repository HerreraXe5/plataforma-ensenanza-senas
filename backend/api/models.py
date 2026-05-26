from django.db import models
from django.contrib.auth.models import User

class Modulo(models.Model):
    titulo = models.CharField(max_length=100)
    descripcion = models.TextField()
    orden = models.IntegerField(default=1)

    def __str__(self):
        return self.titulo

class Sena(models.Model):
    modulo = models.ForeignKey(Modulo, related_name='senas', on_delete=models.CASCADE)
    palabra = models.CharField(max_length=100)
    url_multimedia = models.URLField(max_length=500)
    es_sena_del_dia = models.BooleanField(default=False)

    def __str__(self):
        return self.palabra

# --- NUEVOS MODELOS PARA LAS FUNCIONALIDADES FALTANTES ---

class SenaFavorita(models.Model):
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)
    sena = models.ForeignKey(Sena, on_delete=models.CASCADE)
    fecha_agregada = models.DateTimeField(auto_now_add=True)

class Pregunta(models.Model):
    modulo = models.ForeignKey(Modulo, related_name='preguntas', on_delete=models.CASCADE)
    texto = models.CharField(max_length=255)
    opcion_1 = models.CharField(max_length=100)
    opcion_2 = models.CharField(max_length=100)
    opcion_3 = models.CharField(max_length=100)
    opcion_4 = models.CharField(max_length=100)
    respuesta_correcta = models.IntegerField(help_text="Ingresa 1, 2, 3 o 4")

    def __str__(self):
        return f"{self.modulo.titulo} - {self.texto}"

class ResultadoQuiz(models.Model):
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)
    modulo = models.ForeignKey(Modulo, on_delete=models.CASCADE)
    puntaje = models.IntegerField()
    fecha = models.DateTimeField(auto_now_add=True)