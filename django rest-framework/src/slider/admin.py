from django.contrib import admin
from .models import Slider
# Register your models here.

class DashSlider(admin.ModelAdmin):
    list_display = ('nom','titre','image')

admin.site.register(Slider, DashSlider)