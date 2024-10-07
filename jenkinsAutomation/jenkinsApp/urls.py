
from django.urls import path
from . views import *

app_name = 'jenkinsApp'

urlpatterns = [
    path('health/', HealthCheck.as_view(), name="healthcheck"),
]

