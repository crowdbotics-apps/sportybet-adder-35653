from django.urls import path
from .views import (
    user_update_view,
    user_redirect_view,
    UserUpdateView,
    UserDetailView,
    user_detail_view,
)

app_name = "users"
urlpatterns = [
    path("~redirect/", view=user_redirect_view, name="redirect"),
    path("~update/", view=user_update_view, name="update"),
    path("<str:username>/", view=user_detail_view, name="detail"),
    path("users/<int:pk>/detail/", UserDetailView.as_view(), name="user_detail"),
    path("users/<int:pk>/update/", UserUpdateView.as_view(), name="update_user"),
]
