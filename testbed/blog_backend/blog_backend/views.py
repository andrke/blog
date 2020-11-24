import os
import time
import subprocess

from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils.timezone import now
from django.db import connection  # works with default connection only, use 'connections'

class APIRootView(APIView):
    def get(self, request):
        date = now()
        whom = os.getenv('POWERED_BY', 'Andres Kepler')
        release = os.getenv('WORKFLOW_RELEASE', 'unknown')
        container = subprocess.getoutput('hostname').strip()
        return Response(dict(date=date, whom=whom, release=release, container=container))

# Return 200 for kubernetes healthcheck or 503 if db is broken.
class APIHealthView(APIView):
    def get(self, request):
        connection_data = connection.settings_dict
        connection_data['PASSWORD'] = "_".join(list(map(lambda x: '*', connection_data['PASSWORD'])))
        if connection.is_usable():
            return Response(dict(status="ok", connection=connection_data))
        return Response(dict(status="error", connection=connection_data), code=503)

class APISleepView(APIView):
    def get(self, request):
        date = now()
        container = subprocess.getoutput('hostname').strip()
        sleep = request.GET.get('time')
        if sleep:
            try:
                sleep = int(sleep)
            except Exception:
                sleep = 1
            time.sleep(sleep)
        return Response(dict(date=date, container=container, sleep=sleep))