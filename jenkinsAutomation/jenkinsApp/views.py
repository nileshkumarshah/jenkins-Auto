from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response


# Create your views here.

class HealthCheck(APIView):
    def get(self, request, *args, **kwargs):
        if request is None:
            return Response({"code":200,"message":"Success","status":"OK","data":[]},status=200)
        else:
            return Response({"code":200,"message":"Success","status":"OK","data":[{"status": "UP"}]},status=200)
        
        