# -*- coding: utf-8 -*-

from player import create_app

app = create_app()

"""
gunicorn --bind 127.0.0.1:8000 wsgi:app

"""