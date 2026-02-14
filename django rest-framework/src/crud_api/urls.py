"""
URL configuration for crud_api project.
"""

from django.contrib import admin
from django.urls import path, include

from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('produits.urls')),
    path('', include('contact.urls')),
    path('', include('slider.urls')),
]

# ✅ Sert les fichiers MEDIA en mode DEBUG (images produits, uploads, etc.)
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
