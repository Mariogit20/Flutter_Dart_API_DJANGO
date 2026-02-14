from django.shortcuts import render
from rest_framework import viewsets, status
from .models import Contact
from .serializers import ContactSerializers

from rest_framework.response import Response
from django.core.mail import send_mail
# Create your views here.

class ContactViewSet(viewsets.ModelViewSet):
    queryset = Contact.objects.all()
    serializer_class = ContactSerializers

    def create (self, request, *args, **kwargs):  # *args: parametre tsis anarana / *kags: parametre misy anarana oh:
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            contact = serializer.save()

            #envoi d'email via maildev
            subject= f"Nouveau message de {contact.nom}"
            message = (
                f"Nom : {contact.nom}\n"
                f"Email : {contact.email}\n"
                f"Message : {contact.message}"
            )

            send_mail(
                subject,
                message,
                'no-reply@monapp.com',
                ['admin@monapp.com'], #destinataire (admin)
                fail_silently=False,
            )

            return Response(serializer.data, status= status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
