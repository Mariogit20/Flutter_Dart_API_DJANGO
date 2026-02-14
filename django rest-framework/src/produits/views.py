#from django.shortcuts import render
from rest_framework import viewsets
from .models import Produit
from .serializers import ProduitSerializers
# Create your views here.


class ProduitViewSet(viewsets.ModelViewSet):
    queryset = Produit.objects.all()
    serializer_class = ProduitSerializers