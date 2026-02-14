# from django.db import models

# # Create your models here.
# class Produit(models.Model):
#     nom = models.CharField(max_length=100)
#     description = models.TextField()
#     prix = models.DecimalField(max_digits=10, decimal_places=2)
#     image = models.ImageField(upload_to = "static/image/produits")
#     date_ajout = models.DateTimeField(auto_now_add=True)

from django.db import models

class Produit(models.Model):
    nom = models.CharField(max_length=100)
    description = models.TextField()
    prix = models.DecimalField(max_digits=10, decimal_places=2)
    image = models.ImageField(upload_to="produits/", null=True, blank=True)
    date_ajout = models.DateTimeField(auto_now_add=True)
