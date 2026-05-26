from django.contrib import admin
from .models import Modulo, Sena, Pregunta, SenaFavorita, ResultadoQuiz

# Aquí le decimos a Django qué tablas queremos ver y gestionar en el panel de control
admin.site.register(Modulo)
admin.site.register(Sena)
admin.site.register(Pregunta) # ¡Aquí está la tabla que faltaba!
admin.site.register(SenaFavorita)
admin.site.register(ResultadoQuiz)