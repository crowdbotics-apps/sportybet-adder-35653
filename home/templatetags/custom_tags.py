from django import template
from django.core import serializers
from django.db.models import Model, QuerySet
from django.forms import model_to_dict

register = template.Library()


@register.filter
def jsonify(obj):
    if isinstance(obj, QuerySet):
        return serializers.serialize("json", obj)
    if isinstance(obj, Model):
        return model_to_dict(obj)
    return {}


@register.filter
def model_name(view):
    return view.model.__name__
