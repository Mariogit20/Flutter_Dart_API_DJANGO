from django.db import models

# Create your models here.
class Slider(models.Model):
    nom = models.CharField(max_length=100)
    titre = models.TextField()
    image = models.ImageField(upload_to = "static/image/sliders")

