from django.http import JsonResponse

def obtener_modulos(request):
    data = {
        "seña_del_dia": {"palabra": "Hola", "imagen": "https://api.dicebear.com/7.x/bottts/svg?seed=hola"},
        "modulos": [
            {"id": 1, "titulo": "Alfabeto A-Z", "progreso": 80, "señas_count": 27},
            {"id": 2, "titulo": "Números Básicos", "progreso": 40, "señas_count": 10},
            {"id": 3, "titulo": "Saludos Comunes", "progreso": 0, "señas_count": 15},
        ]
    }
    return JsonResponse(data)