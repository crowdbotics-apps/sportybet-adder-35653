from rest_framework import authentication
from sportybetadder.models import Sportybetadder
from .serializers import SportybetadderSerializer
from rest_framework import viewsets


class SportybetadderViewSet(viewsets.ModelViewSet):
    serializer_class = SportybetadderSerializer
    authentication_classes = (
        authentication.SessionAuthentication,
        authentication.TokenAuthentication,
    )
    queryset = Sportybetadder.objects.all()
