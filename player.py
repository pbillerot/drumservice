# -*- coding: utf-8 -*-

from flask import Flask, Blueprint
from flask import request, g, current_app
import pygame
import time
import os

profile = Blueprint('main', __name__, url_prefix="/")

#Initialisation Pygame
pygame.mixer.init()

@profile.route('/')
def player():
  return 'Player à votre écoute\n'

@profile.route('/play/<mediafile>')
def play(mediafile):
  if "son" in  current_app.config:
    current_app.config["son"].stop()
  filePath = os.path.join(profile.root_path, 'media', mediafile)
  son = pygame.mixer.Sound(filePath)
  son.play(-1)
  current_app.config["son"] = son
  return 'Media: play {}\n'.format(mediafile)

@profile.route('/stop')
def stop():
  if "son" in  current_app.config:
    current_app.config["son"].stop()
  return 'Media: stop\n'

if __name__ == '__main__':
  # global app
  app = Flask(__name__)
  app.register_blueprint(profile)
  app.run()

def create_app():
  app = Flask(__name__)
  app.register_blueprint(profile)
  return app

app = create_app()

"""
curl http://0.0.0.0:1953
curl http://0.0.0.0:1953/play/drums_100.wav
curl http://0.0.0.0:1953/play/drums_117.wav
curl http://0.0.0.0:1953/stop
"""