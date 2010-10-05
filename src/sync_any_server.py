from twisted.enterprise import adbapi, util as dbutil
from twisted.cred import credentials, portal, checkers, error as credError
from twisted.internet import reactor, defer, protocol, ssl

import json
from zope.interface import Interface, implements

import ConfigParser
import os
import logging
import logging.config
from twisted.protocols import basic
import MySQLdb
import MySQLdb.cursors
import pprint
from twisted.internet.protocol import Protocol, connectionDone
from twisted.python.hashlib import md5

from vo.user import User, IUser 

import uuid
from dbo.DboMySQL import DboMySQL
from datetime import datetime
import random
from models.entity import Entity
from models.client import Client
from vo.clients import Clients
from config.loggger import Logger
from models.transaction import Transaction

#logging.config.fileConfig(os.curdir + "/config/logging.cfg")
#log = logging.getLogger("SyncAnyServer")
#log.setLevel(logging.DEBUG)

log = Logger.get("SyncAnyServer")

config = ConfigParser.ConfigParser()
config.read(os.curdir + "/config/core.cfg")

#class Clients:
#    
#    def __init__(self):
#        self.clients = {}
#    
#    def __checkClientInstance(self, client):
#        if not isinstance(client, SyncAnyProtocol):
#            log.exception("Client must be a 'SyncAnyProtocol' instance: %s" % repr(client))
#            raise TypeError, "Client must be a 'SyncAnyProtocol' instance" 
#    
#    def hasClient(self, client):
#        log.info('Clients::hasClient')
#        log.debug(client)
#        self.__checkClientInstance(client)
#        
#        scope = client.user.id
#        
#        has = False
#        if self.clients.has_key(scope):
#            try:
#                self.clients.get(scope).index(client)
#                has = True
#            except Exception, e:
#                pass
#
#        return has
#    
#    def addClient(self, client):
#        log.info('Clients::addClient')
#        log.debug(client)
#        self.__checkClientInstance(client)
#        
#        scope = client.user.id
#        if not self.clients.has_key(scope):
#            self.clients[scope] = []
#            
#        self.clients.get(scope).append(client)
#        
#        log.debug(self.clients)
#    
#    def removeClient(self, client):
#        log.info('Clients::removeClient')
#        log.debug(client)
#        self.__checkClientInstance(client)
#        
#        if self.hasClient(client):
#            scope = client.user.id
#            self.clients.get(scope).remove(client)
#            if len(self.clients.get(scope)) == 0:
#                del self.clients[scope]
#    
#        log.debug(self.clients)
#    
#    def getClients(self, scope):
#        log.info('Clients::getClients')
#        log.debug(scope)
#        return self.clients
    

class DbAuthChecker(object):

    implements(checkers.ICredentialsChecker)
    credentialInterfaces = (credentials.IUsernamePassword, credentials.IUsernameHashedPassword)

    def __init__(self, dbconn):
        log.info('DbAuthChecker::__init__')
        
        self.dbconn = dbconn

    def requestAvatarId(self, credentials):
        log.info('DbAuthChecker::requestAvatarId')
        log.debug(credentials)

        query = """SELECT 
                        id, password
                    FROM 
                        users 
                    WHERE 
                        email = %s AND password = %s""" % (dbutil.quote(credentials.username, "char"), dbutil.quote(credentials.password, "char"))
        log.debug('query: ' + query)

        return self.dbconn.runQuery(query).addCallback(self._gotQueryResults, credentials)


    def _gotQueryResults(self, rows, userCredentials):
        log.info('DbAuthChecker::_gotQueryResults')
        log.debug(rows)
        log.debug(userCredentials)

        if rows:
            row = rows[0]
            return defer.maybeDeferred(userCredentials.checkPassword, row['password']).addCallback(self._checkedPassword, row['id'])
        else:
            log.warning("No such user")
            raise credError.UnauthorizedLogin, "No such user"

    def _checkedPassword(self, matched, id):
        log.info('DbAuthChecker::_checkedPassword')
        log.debug(id)

        if matched:
            return id
        else:
            raise credError.UnauthorizedLogin("Bad password")

class DbRealm:

    implements(portal.IRealm)

    def __init__(self, dbconn):
        log.info('DbRealm::__init__')

        self.dbconn = dbconn

    def requestAvatar(self, avatarId, mind, *interfaces):
        log.info('DbRealm::requestAvatar')
        log.debug(avatarId)
        log.debug(mind)

        if IUser in interfaces:

            query = """SELECT 
                                * 
                            FROM 
                                users 
                            WHERE id = %s""" % dbutil.quote(avatarId, "int")

            return self.dbconn.runQuery(query).addCallback(self._gotQueryResults)
        else:
            raise KeyError("None of the requested interfaces is supported")

    def _gotQueryResults(self, rows):
        log.info('DbRealm::_gotQueryResults')
        log.debug(rows)

        row = rows[0]

        return (IUser, User(row['id'], row['first_name'], row['last_name'], row['password'], row['email'], row['plan']), lambda: None) # null logout function


class SyncAnyProtocol(Protocol):
#class SyncAnyProtocol(basic.LineReceiver):
    
    def __init__(self):
        self.started = False
        self.instance = None
        self.session = None
        self.user = None
        self.client_id = None
        self.client_hash = None
        self.delimiter = '\r\n'

#    def lineReceived(self, line):
#        log.info('SyncAnyProtocol::lineReceived')
#        log.debug(line)
#
#        services = [self.factory, self, ]
#
#        try:
#            params = json.loads(line)
#            
#            for service in services:
#                cmd = getattr(service, 'call_' + params['call'], None)
#                if cmd is not None:
#                    responce = cmd(params)
#                    log.debug('Responce: %s' % responce)
#                    
#                    #if params['call'] != 'login':
#                    #    self.sendLine(responce)
#                else:
#                    log.error("Undefined method: call_%s in %s" % (params['call'], service))
#        except Exception, e:
#            log.exception("Exception: %s" % e)

    def dataReceived(self, data):
        log.info('SyncAnyProtocol::dataReceived')
        log.debug(data)

        buffer = self.buffer + data
        packages = buffer.split(self.delimiter)
        if len(packages) != 0:
            self.buffer = packages.pop()
        else:
            self.buffer = '' 
        
        log.debug('Packages: %s' % packages)
        
        for package in packages:
            if package == '': continue
            
            try:
                params = json.loads(package)
                log.debug(params)
                call = params['call']
                
                cmd = getattr(self, 'call_' + call, None)
                if cmd is not None:
                    responce = cmd(params)
                    log.debug('Responce: %s' % responce)
                else:
                    log.error("Undefined method: call_%s in %s" % (call, self))
                
            except Exception, e:
                log.exception("Received data decoding error: %s" % e)
 
    def connectionMade(self):
        log.info('SyncAnyProtocol::connectionMade')
        self.buffer = ''
        #self.factory.clients.append(self)
        
        #self.transport.write("authenticate")
        #self.sendLine("authenticate")
        #self.sendData("authenticate")

    def sendData(self, data):
        log.info('SyncAnyProtocol::sendData')
        package = "%s%s" % (data, self.delimiter)
        log.debug(package) 
        self.transport.write(package)

    def connectionLost(self, reason = connectionDone):
        log.info('SyncAnyProtocol::connectionLost')
        
        self.started = False
        Protocol.connectionLost(self, reason)
        
        #self.factory.clients.remove(self)
        if not self.user is None:
            self.factory.clients.removeClient(self)


    def call_login(self, params):
        log.info('SyncAnyProtocol::call_login')
        log.debug(params)
        
        if self.session == None:
            username = None
            password = None
            if params.has_key('email'): 
                username = params['email']
                
            if params.has_key('password'): 
                password = params['password']
                
            if params.has_key('instance'):
                self.instance = params['instance']
                
            if params.has_key('client_hash'):
                self.client_hash = params['client_hash']
                
            creds = credentials.UsernamePassword(username, password)
            self.factory.portal.login(creds, None, IUser).addCallback(self._loginSucceeded).addErrback(self._loginFailed)
        else:
            log.warning('User already logged')
            #self.sendLine({'session': self.session})

#    def callAddEntity(self, params):
#        log.info('SyncAnyProtocol::callAddEntity')
#        log.debug(params)
#
#        result = self.factory.Entity.addEntity(self.user.id, self.client_id, params)
#        #self.sendLine(json.dumps(result))
#        self.sendData(json.dumps(result))
    
    def call_syncEntities(self, params):
        log.info('SyncAnyProtocol::call_syncEntities')

        result = self.factory.Entity.syncEntities(self.user.id, self.client_id, params)
        #self.sendLine(json.dumps(result))
        self.sendData(json.dumps(result))

#    def call_syncEntitiesFromDate(self, params):
#        log.info('SyncAnyProtocol::call_syncEntitiesFromDate')
#
#        result = self.factory.Entity.syncEntitiesFromDate(self.user.id, self.client_id, params)
#        #self.sendLine(json.dumps(result))
#        self.sendData(json.dumps(result))

#    def call_removeEntity(self, params):
#        log.info('SyncAnyProtocol::call_removeEntity')
#        log.debug(params)
#        
#        line = {
#            'result': 'ok' # or fail #@todo: make constants !!!!
#        }
#        #self.sendLine(json.dumps(line))
#        self.sendData(json.dumps(line))
#        
#        pass
    
#    def call_syncEntities(self, params):
#        log.info('SyncAnyProtocol::call_syncEntities')
#        log.debug(params)
#        
#        line = {
#            'path': params['path'], 
#            'modified': params['modified'], 
#            'size': params['size'], 
#            'hash': "a1729bc110c",
#            'action': "upload",
#            'ticket': "1affe36"
#        }
#        self.sendLine(json.dumps(line))
#        pass

    def call_updateEntity(self, params):
        log.info('SyncAnyProtocol::call_updateEntity')
        log.debug(params)
        
        
        # get transaction by ticket
        user_id = 2
        client_id = 81
        
        #self.client_id
        clients = self.factory.clients.getClients(user_id)
        log.debug(clients)
        
        #dispatch
        #if not clients is None:
        #    for client in clients:
        #        client.sendResponse();
                

    def call_sendLog(self, params):
        log.info('SyncAnyProtocol::call_sendLog')
        log.debug(params)
        pass
    
    def call_updateProfile(self, params):
        log.info('SyncAnyProtocol::call_updateProfile')
        log.debug(params)
        
#        rowcount = self.factory.dbo.update("""
#                UPDATE users SET total_won_games = %s WHERE id = %s
#            """ % (dbutil.quote(self.instance, "varchar"), dbutil.quote(self.user.id, "int")))
        
        pass

    def _loginSucceeded(self, avatarInfo):
        log.info('SyncAnyProtocol::_loginSucceeded')
        log.debug(avatarInfo)

        try:
            avatarInterface, self.user, logout = avatarInfo
            
            if self.user is None:
                raise credError.UnauthorizedLogin, "No such user" 
            
            self.started = True
            self.session = md5(str(uuid.uuid4())).hexdigest()
            self.factory.clients.addClient(self)

            client = self.factory.Client.findByHash(self.client_hash)
            
            if client is None:
                log.debug('Client was not found by client_hash %s' % self.client_hash)
                data = {
                    'user_id': self.user.id,
                    'client_hash': self.client_hash,
                    'client': self.instance,
                }
                self.client_id = self.factory.Client.addClient(data)
            else:
                log.debug('Client was found %s' % client)
                self.client_id = client['id']

            responce =  {
                'command': 'login',
                'session': self.session,
                'error': 0
            }
            #self.sendLine(json.dumps(responce))
            self.sendData(json.dumps(responce))
        except Exception, e:
            log.exception("Exception: %s" % e)
            log.exception('The avatarInfo is: %s' % avatarInfo)
            defer.maybeDeferred(logout).addBoth(self._logoutFinished)

    def _logoutFinished(self, result):
        log.info('SyncAnyProtocol::_logoutFinished')

        self.transport.loseConnection( )

    def _loginFailed(self, failure):
        log.info('SyncAnyProtocol::_loginFailed')

        #self.transport.write("Denied: %s.\r\n" % failure.getErrorMessage( ))
        
        #line = {
        #    'error': repr(failure.type),
        #    'message': failure.getErrorMessage() 
        #}
        #self.sendData(json.dumps(line))

        responce =  {
            'command': 'login',
            'session': self.session,
            'error': 1,
            'error_message': failure.getErrorMessage()
        }
        self.sendData(json.dumps(responce))

        self.transport.loseConnection( )


class SyncAnyFactory(protocol.Factory):

    protocol = SyncAnyProtocol

    def __init__(self, portal):
        log.info('SyncAnyFactory::__init__')
        
        self.portal = portal
        #self.clients = []
        self.clients = Clients()
        #self.services = {'Entities': Entities()}
        
        #self.dbo = DboMySQL(config)
        #self.dbo.connect()
        self.dbo = DboMySQL()

    def startFactory(self):
        log.info('SyncAnyFactory::startFactory')
        
        # create all nessesary paths
#        options = config.items("path")
#        print options
#        for option in options:
#            path = os.curdir + options[option]
#            if not os.path.isdir(path):
#                os.mkdir(path)
        
        
        self.Entity = Entity()
        self.Transaction = Transaction()
        self.Client = Client()
        #self.User = User()
        
#        storage_path = os.curdir + config.get("path", "storage")
#        if not os.path.isdir(storage_path):
#            os.mkdir(storage_path)
#
#        tmp_path = os.curdir + config.get("path", "tmp")
#        if not os.path.isdir(tmp_path):
#            os.mkdir(tmp_path)

    
    def stopFactory(self):
        log.info('SyncAnyFactory::stopFactory')
        self.dbo.disconnect()
        pass 


if __name__ == "__main__":

    db_args = {
        'db': config.get("database", "database"),
        'user': config.get("database", "login"),
        'passwd': config.get("database", "password"),
        'use_unicode': config.get("database", "unicode"),
        'cursorclass': MySQLdb.cursors.DictCursor,
        'charset': config.get("database", "charset"),
    }
    connection = adbapi.ConnectionPool(config.get("database", "driver"), **db_args)
    p = portal.Portal(DbRealm(connection))
    p.registerChecker(DbAuthChecker(connection))

    factory = SyncAnyFactory(p)
    ssl_keys_path = config.get("ssl", "keys_path")
    reactor.listenSSL(int(config.get("app", "port")), factory, ssl.DefaultOpenSSLContextFactory(ssl_keys_path + config.get("ssl", "private_key"), ssl_keys_path + config.get("ssl", "certificate")))
    reactor.run( )
