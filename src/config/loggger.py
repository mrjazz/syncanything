import os
import logging
import logging.config

logging.config.fileConfig(os.path.dirname(__file__) + "/logging.cfg")
level = logging.DEBUG

class Logger:
    
    @staticmethod
    def get(name):
        log = logging.getLogger(name)
        log.setLevel(level)
        return log