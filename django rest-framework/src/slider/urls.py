from django.urls import path,include
from rest_framework.routers import DefaultRouter
from .views import SliderViewSet

router = DefaultRouter()
router.register(r'slider',SliderViewSet)

urlpatterns = [
    path('',include(router.urls))
]
