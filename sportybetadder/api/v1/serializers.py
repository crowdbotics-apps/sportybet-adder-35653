from rest_framework import serializers
from sportybetadder.models import Sportybetadder


class SportybetadderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sportybetadder
        fields = "__all__"
