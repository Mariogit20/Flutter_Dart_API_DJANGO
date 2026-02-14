#from django.shortcuts import render
from rest_framework import viewsets
from .models import Slider
from .serializers import SliderSerializers
# Create your views here.


class SliderViewSet(viewsets.ModelViewSet):
    queryset = Slider.objects.all()
    serializer_class = SliderSerializers
    