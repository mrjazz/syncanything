from twisted.enterprise import util as dbutil
from datetime import datetime

import random
from twisted.python.hashlib import md5

import os
import ConfigParser
from dbo.DboMySQL import DboMySQL
from models.transaction import Transaction
from app_model import AppModel
import json
from vendors.utils import File, Datetime

from config.loggger import Logger
import re
log = Logger.get("Model")

config = ConfigParser.ConfigParser()
config.read(os.curdir + "/config/core.cfg")

NONE = -1
UPLOAD = 0
DOWNLOAD = 1
DELETE = 2

class Entity(AppModel):
    def __init__(self):
        log.info('Entity::__init__')
        
        self.dbconn = DboMySQL()
        self.table = 'entities'
        self._fields = self._getFields()
        
        self.storage_path = os.path.abspath(config.get("path", "storage"))
        
        self.Transaction = Transaction()
    
    def __actionToInt(self, action):
        log.info('Entity::__actionToInt')
        log.debug(action)
        
        result = None
        if action == 'upload':
            result = UPLOAD
        elif action == 'download': 
            result = DOWNLOAD
        elif action == 'delete':
            result = DELETE

        return result
    
    def __getSkipedEntities(self, params):
        rows = self.Transaction.getSkiped(params)
        skiped_entities = self.Transaction.prepareToClient(rows)
        for entity in skiped_entities:
            if entity['action'] == 'upload':
                entity['action'] = 'download'
        
        return skiped_entities
    
    def syncEntities(self, user_id, client_id, params):
        log.info('Entity::syncEntities')
        log.debug(params)
        
        #get unfinished transactions
        data = {
            'user_id': user_id,
            'client_id': client_id,
            'finished': self.Transaction.getLastSyncedDate(user_id, client_id)
        }
        log.debug(data)
        entities = self.__getSkipedEntities(data)
        
        # !!!!!! ADD REMOVE EXPIRED TRANSACTION
        self.Transaction.removeUncompleted(user_id, client_id)
        
        # ????
        #rows = self.Transaction.getUnCompleted(user_id, client_id)
        #entities = self.Transaction.prepareToClient(rows)
        #entities = entities + skiped_entities
        
        log.debug('Previous skiped transactions:')
        log.debug(entities)
        
        if params.has_key('entities'):
            data = {
                'user_id': user_id,
                'client_id': client_id
            }
            tickets = self.__sync(data, params.get('entities'))

        if len(tickets) > 0:
            log.debug('Tickets: %s' % tickets)
            rows = self.Transaction.findByUserTickets(user_id, client_id, tickets)
            rows = self.Transaction.prepareToClient(rows)
            entities = entities + rows 

        log.debug('Entities: %s' % entities)
        entities = {
            'command': 'syncEntities',
            'entities': entities
        }

        return entities
    
    def __sync(self, params, entities):
        log.info('Entity::__sync')
        log.debug(entities)
        
        tickets = []
        try:
            for entity in entities:
                type, path = entity.get('path').split(':')

                if type == 'files':
                    switch = self.__files(params.get('user_id'), params.get('client_id'), entity)
                else:
                    switch = self.__undefined(type, entity)
                
                #switch = {
                #    'files': self.__files(params.get('user_id'), params.get('client_id'), entity)
                #}.get(type, self.__undefined(type, entity))
                
                if not switch is None:
                    tickets.append(switch)
                    
        except Exception, e:
            log.error('Entities synchronization error %s' % repr(e))
        
        return tickets
    
    def __undefined(self, type, entity):
        log.info('Entity::__undefined')
        log.debug(entity)
        log.debug('Cannot synchronize this entity type: %s' % type)
        return None
    
    def __files(self, user_id, client_id, param):
        log.info('Entity::__files')
        log.debug(param)
        log.debug({'user_id': user_id, 'client_id': client_id})
        
        ticket = None
        #try:
        path = param.get('path')
        size = param.get('size')
        #modified = datetime.strptime(param.get('modified'), "%d-%m-%Y %H:%M:%S")
        modified = Datetime.str_to_utc(param.get('modified'))
        filedate = str(modified.strftime("%Y-%m-%d %H:%M:%S"))
        hash = param.get('hash')
        
        # check for valid incoming params
        
        removed = False
        if param.has_key('removed'):
            removed = (param.get('removed') == True 
                       or param.get('removed') == 'true' 
                       or param.get('removed') == 'True')
            
        
        fileFolder = '/'.join(re.compile(r".{1}", re.DOTALL).findall(hash)) 
        
        storedFolder = os.path.normpath("%s/%s/" % (self.storage_path, fileFolder))
        storedFile = "%s/%s" % (storedFolder, hash) 

        type, folders_path = path.split(':')

        #######################################
#        f = stored + folders_path
#        log.debug('Type: %s' % type)
#        log.debug('Path: %s' % f)
#        if os.path.isfile(f):
#            fdata = json.loads(open(f).read())
#            if removed == True:
#                if modified > fdata['modified']:
#                    action = DELETE
#            elif hash != fdata['hash'] or size != fdata['size']:
#                if modified > fdata['modified']:
#                    action = UPLOAD
#                elif modified < fdata['modified']:
#                    action = DOWNLOAD
#            
#            return ticket   
#        else:
#            action = UPLOAD
#            data = {
#                'path': path,
#                'modified': filedate, 
#                'size': size, 
#                'hash': hash,
#            }
#            
#            created = File.create(f, json.dumps(data))
#            if created is False:
#                log.critical('Cannot create file by path: %s' % f)
#                return ticket
        #######################################

        if removed == True:
            action = DELETE
        elif os.path.isfile(storedFile):
            return ticket
#            if modified > fdata['modified']:
#                action = UPLOAD
#            elif modified < fdata['modified']:
#                action = DOWNLOAD
        else:
            action = UPLOAD

        ################## old functionality
#            f = stored + folders_path
#            if removed == True:
#                if os.path.isfile(f):
#                    if modified <= os.path.getmtime(f):
#                        return ticket
#                
#                action = DELETE
#            else:
#                action = UPLOAD
#                if os.path.isfile(f):
#                    if hash != crc32(open(f).read()):
#                        if modified > os.path.getmtime(f):
#                            action = UPLOAD
#                        elif modified < os.path.getmtime(f):
#                            action = DOWNLOAD
#                        else:
#                            return ticket
#                            #if os.path.exists(f):
        ##################
        
        log.debug('Transaction action: %s' % action)
        
        data = {
            'user_id': user_id, 
            'path': path,
            'size': size,
            'filedate': filedate,
            'hash': hash,
            'stored': storedFolder 
        }
        entity_id = self.create(data)

        if entity_id != None:
            new_ticket = md5("%s" % (random.random())).hexdigest()
            
            data = {
                'user_id': user_id, 
                'entity_id': entity_id,
                'client_id': client_id,
                'ticket': new_ticket,
                'action': action
            }
            transaction_id = self.Transaction.create(data)
             
            if transaction_id != None:
                rowcount = self.update({'transaction_id': transaction_id}, {'id': entity_id}) 

                ticket = new_ticket
            else:
                log.error('Undefined inserted transaction id')
        else:
            log.error('Undefined inserted entity id')
                   
        #except Exception, e:
        #    log.error('Incoming parameters is invalid %s' % repr(e))
        
        return ticket
    
    def create(self, data):
        log.info('Entity::create')
        log.debug(data)
        
        data = self._quote(data)
        return self.dbconn.insert("""
            INSERT INTO %s
                (`user_id`,
                `transaction_id`,
                `path`,
                `size`,
                `filedate`,
                `hash`,
                `stored`,
                `created`,
                `modified`)
            VALUES
                (%s, 
                0, 
                %s,
                %s,
                %s,
                %s,
                %s,
                NOW(), 
                NOW())
        """ % (
               self.table,
               data.get('user_id'), 
               data.get('path'),
               data.get('size'),
               data.get('filedate'),
               data.get('hash'),
               data.get('stored')
            )
        )
         
    def update(self, data, where):
        log.info('Entity::update')
        log.debug(data)
        log.debug(where)
        
        data = self._quote(data)
        where = self._quote(where)

        fields = []
        for f in data:
            fields.append("%s = %s" % (f, data[f]))

        whr = []
        for f in where:
            whr.append("%s = %s" % (f, where[f]))

        return self.dbconn.update("""
                UPDATE 
                    %s 
                SET 
                    %s 
                WHERE 
                    %s
            """ % (
                   self.table,
                   ', '.join(fields), 
                   ' AND '.join(whr),
                )
            )
#        
#    def addEntity(self, user_id, client_id, params):
#        log.info('Entity::addEntity user_id(%s), client_id(%s) ' % (user_id, client_id))
#        log.debug(params)
#        
#        ticket = None
#        try:
#            path = params.get('fileInfo').get('path')
#            size = params.get('fileInfo').get('size')
#            modified = datetime.strptime(params.get('fileInfo').get('modified'), "%d-%m-%Y %H:%M:%S")
#            filedate = modified.strftime("%Y-%d-%m %H:%M:%S")
#            hash = params.get('fileInfo').get('hash')
#            
#            stored = "%s%s/" % (self.storage_path, str(user_id))
#            
#            # action: int (0 - upload, 1 - download, 2 - delete)
#            action = UPLOAD
#            
#            entity_id = self.dbconn.insert("""
#                INSERT INTO `entities`
#                    (`user_id`,
#                    `transaction_id`,
#                    `path`,
#                    `size`,
#                    `filedate`,
#                    `hash`,
#                    `stored`,
#                    `created`,
#                    `modified`)
#                VALUES
#                    (%s, 
#                    %s, 
#                    %s,
#                    %s,
#                    %s,
#                    %s,
#                    %s,
#                    NOW(), 
#                    NOW())
#            """ % (dbutil.quote(user_id, "int"), 
#                   dbutil.quote(0, "int"),
#                   dbutil.quote(path, "varchar"),
#                   dbutil.quote(size, "int"),
#                   dbutil.quote(filedate, "timestamp"),
#                   dbutil.quote(hash, "varchar"),
#                   dbutil.quote(stored, "varchar"))
#            )
#            
#            if entity_id != None:
#                new_ticket = md5("%s%s" % (config.get('security', 'salt'), random.random())).hexdigest()
#                
#                transaction_id = self.dbconn.insert("""
#                    INSERT INTO `transactions`
#                        (`user_id`,
#                        `entity_id`,
#                        `client_id`,
#                        `ticket`,
#                        `started`,
#                        `action`,
#                        `created`,
#                        `modified`)
#                    VALUES
#                        (%s, 
#                        %s, 
#                        %s,
#                        %s,
#                        NOW(),
#                        %s,
#                        NOW(), 
#                        NOW())
#                """ % (dbutil.quote(user_id, "int"), 
#                       dbutil.quote(entity_id, "int"),
#                       dbutil.quote(client_id, "int"),
#                       dbutil.quote(new_ticket, "varchar"),
#                       dbutil.quote(action, "int"))
#                )
#                 
#                if transaction_id != None:
#                    rowcount = self.dbconn.update("""
#                        UPDATE entities SET transaction_id = %s WHERE id = %s
#                    """ % (dbutil.quote(transaction_id, "int"), dbutil.quote(entity_id, "int")))
#                    
#                    if rowcount > 0:
#                        ticket = new_ticket
#                    else:
#                        log.error('Cannot update transaction_id(%s) in table entities by entity_id(%s)' % (transaction_id, entity_id))
#                else:
#                    log.error('Undefined inserted transaction id')
#            else:
#                log.error('Undefined inserted entity id')
#                   
#        except Exception, e:
#            log.error('Incoming parameters is invalid %s' % repr(e))
#
#        return {'ticket': ticket}
#    
#    def old_updateEntity(self, user_id, client_id, params):
#        log.info('Entity::updateEntity user_id(%s), client_id(%s) ' % (user_id, client_id))
#        log.debug(params)
#        
#        update_ticket = None
#        try:
#            path = params.get('fileInfo').get('path')
#            size = params.get('fileInfo').get('size')
#            modified = datetime.strptime(params.get('fileInfo').get('modified'), "%d-%m-%Y %H:%M:%S")
#            filedate = modified.strftime("%Y-%d-%m %H:%M:%S")
#            hash = params.get('fileInfo').get('hash')
#            
#            ticket = params.get('fileInfo').get('ticket')
#            action = self.__actionToInt(params.get('fileInfo').get('action'))
#            if action == None:
#                raise AppException("Undefined action for entity: %s" % params.get('fileInfo').get('action'))
#            
#            
#            transaction = self.dbconn.query("""
#                SELECT 
#                    * 
#                FROM 
#                    transactions 
#                WHERE 
#                    ticket = %s""" % (dbutil.quote(ticket, "varchar")))
#            
#            if len(transaction) == 0:
#                log.info('Cannot find transaction by ticket: %s' % ticket)
#            else:
#                log.info('Found transaction by ticket: %s' % ticket)
#                
#                transaction_id = transaction[0]['id']
#                entity_id = transaction[0]['entity_id']
#                
#                rowcount = self.dbconn.update("""
#                    UPDATE 
#                        entities 
#                    SET 
#                        path = %s,
#                        size = %s,
#                        filedate = %s,
#                        hash = %s,
#                        modified = NOW()
#                    WHERE 
#                        id = %s AND 
#                        transaction_id = %s AND 
#                        user_id = %s
#                """ % (
#                       dbutil.quote(path, "varchar"),
#                       dbutil.quote(size, "int"),
#                       dbutil.quote(filedate, "timestamp"),
#                       dbutil.quote(hash, "varchar"),
#                       # where
#                       dbutil.quote(entity_id, "int"),
#                       dbutil.quote(transaction_id, "int"),
#                       dbutil.quote(user_id, "int")))
#                
#                if rowcount > 0:
#                    if action != transaction[0]['action']:
#                        rowcount = self.dbconn.update("""
#                            UPDATE 
#                                transactions 
#                            SET 
#                                action = %s 
#                            WHERE id = %s
#                        """ % (
#                               dbutil.quote(action, "int"), 
#                               dbutil.quote(transaction_id, "int")))
#                        
#                    if rowcount > 0:
#                        update_ticket = ticket
#                    else:
#                        log.error('Cannot update action in transactions(%s)' % (action, transaction_id))
#                else:
#                    log.error('Cannot update entities by entity_id(%s)' % (entity_id))
#            
#        except Exception, e:
#            log.error('Incoming parameters is invalid %s' % repr(e))
#        
#        return {'ticket': update_ticket}
#    
#    def removeEntity(self, user_id, client_id, params):
#        log.info('Entity::removeEntity user_id(%s), client_id(%s) ' % (user_id, client_id))
#        log.debug(params)
#        
#        try:
#            path = params.get('fileInfo').get('path')
#            size = params.get('fileInfo').get('size')
#            modified = datetime.strptime(params.get('fileInfo').get('modified'), "%d-%m-%Y %H:%M:%S")
#            filedate = modified.strftime("%Y-%d-%m %H:%M:%S")
#            hash = params.get('fileInfo').get('hash')
#            
#            stored = "%s%s/" % (self.storage_path, str(user_id))
#            
#            # action: int (0 - upload, 1 - download, 2 - delete)
#            action = DELETE
#            
#            entity_id = self.dbconn.insert("""
#                INSERT INTO `entities`
#                    (`user_id`,
#                    `transaction_id`,
#                    `path`,
#                    `size`,
#                    `filedate`,
#                    `hash`,
#                    `stored`,
#                    `created`,
#                    `modified`)
#                VALUES
#                    (%s, 
#                    %s, 
#                    %s,
#                    %s,
#                    %s,
#                    %s,
#                    %s,
#                    NOW(), 
#                    NOW())
#            """ % (dbutil.quote(user_id, "int"), 
#                   dbutil.quote(0, "int"),
#                   dbutil.quote(path, "varchar"),
#                   dbutil.quote(size, "int"),
#                   dbutil.quote(filedate, "timestamp"),
#                   dbutil.quote(hash, "varchar"),
#                   dbutil.quote(stored, "varchar"))
#            )
#            
#            if entity_id != None:
#                new_ticket = md5("%s%s" % (config.get('security', 'salt'), random.random())).hexdigest()
#                
#                transaction_id = self.dbconn.insert("""
#                    INSERT INTO `transactions`
#                        (`user_id`,
#                        `entity_id`,
#                        `client_id`,
#                        `ticket`,
#                        `started`,
#                        `action`,
#                        `created`,
#                        `modified`)
#                    VALUES
#                        (%s, 
#                        %s, 
#                        %s,
#                        %s,
#                        NOW(),
#                        %s,
#                        NOW(), 
#                        NOW())
#                """ % (dbutil.quote(user_id, "int"), 
#                       dbutil.quote(entity_id, "int"),
#                       dbutil.quote(client_id, "int"),
#                       dbutil.quote(new_ticket, "varchar"),
#                       dbutil.quote(action, "int"))
#                )
#                 
#                if transaction_id != None:
#                    rowcount = self.dbconn.update("""
#                        UPDATE entities SET transaction_id = %s WHERE id = %s
#                    """ % (dbutil.quote(transaction_id, "int"), dbutil.quote(entity_id, "int")))
#                    
#                    if rowcount > 0:
#                        ticket = new_ticket
#                    else:
#                        log.error('Cannot update transaction_id(%s) in table entities by entity_id(%s)' % (transaction_id, entity_id))
#                else:
#                    log.error('Undefined inserted transaction id')
#            else:
#                log.error('Undefined inserted entity id')
#                   
#        except Exception, e:
#            log.error('Incoming parameters is invalid %s' % repr(e))
#            
#        return {'ticket': ticket} 

    
    