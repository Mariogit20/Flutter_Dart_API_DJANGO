from django.contrib import admin
from .models import Produit
# Register your models here.

class DashProduit(admin.ModelAdmin):
    list_display = ('nom','description','prix','image')

admin.site.register(Produit, DashProduit)