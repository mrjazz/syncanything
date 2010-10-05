from dbo.DboMySQL import DboMySQL
from twisted.enterprise import util as dbutil

import os
from app_model import AppModel
from config.loggger import Logger
log = Logger.get("Model")

class Client(AppModel):
    
    def __init__(self):
        log.info('Client::__init__')
        
        self.dbconn = DboMySQL()
        self.table = 'clients'
        self._fields = self._getFields()
    
    def findByHash(self, hash):
        log.info('Client::findByHash')
        log.debug(hash)
        
        data = {
            'client_hash': hash
        }
        data = self._quote(data)
        log.debug(data)
        rows = self.dbconn.query("""
            SELECT 
                *
             FROM %s
             WHERE
                 client_hash = %s LIMIT 1
            """ % (
                   self.table,
                   data.get('client_hash')
                )
            )
        
        if not rows is None and len(rows) > 0:
            return rows[0]
        
        return None
    
    def addClient(self, data):
        log.info('Client::addClient')
        log.debug(data)
        
        data = self._quote(data)
        return self.dbconn.insert("""
                INSERT INTO %s (user_id, client_hash, client, created, modified)
                VALUES
                    (%s, %s, %s, NOW(), NOW())
            """ % (
                   self.table,
                   data.get('user_id'), 
                   data.get('client_hash'),
                   data.get('client'))
            )
