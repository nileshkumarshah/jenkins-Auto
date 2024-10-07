#!/bin/bash

exec python3 manage.py runserver 0.0.0.0:8082 
# exec gunicorn -b 0.0.0.0:8080 --timeout 300 -w 3 -k gevent reporting_service.wsgi:application &
# exec python3 manage.py indus_documents_mask &
# exec python3 manage.py mas_documents_mask