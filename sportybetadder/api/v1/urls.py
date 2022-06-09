from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .viewsets import SportybetadderViewSet

router = DefaultRouter()
router.register("sportybetadder", SportybetadderViewSet)

urlpatterns = [
    path("", include(router.urls)),
]
