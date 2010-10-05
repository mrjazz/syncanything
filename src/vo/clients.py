import os
import logging
import logging.config
#from twisted.protocols import basic
from twisted.internet.protocol import Protocol


logging.config.fileConfig(os.curdir + "/config/logging.cfg")
log = logging.getLogger("SyncAnyServer")
log.setLevel(logging.DEBUG)

class Clients:
    
    def __init__(self):
        self.clients = {}
    
    def __checkClientInstance(self, client):
        #if not isinstance(client, SyncAnyProtocol):
        #if not isinstance(client, basic.LineReceiver):
        if not isinstance(client, Protocol):
            log.critical("Client must be a 'SyncAnyProtocol' instance: %s" % repr(client))
            raise TypeError, "Client must be a 'SyncAnyProtocol' instance" 
    
    def hasClient(self, client):
        log.info('Clients::hasClient')
        log.debug(client)
        self.__checkClientInstance(client)
        
        scope = client.user.id
        
        has = False
        if self.clients.has_key(scope):
            try:
                self.clients.get(scope).index(client)
                has = True
            except Exception, e:
                log.exception('Cannot check client: %s' % client)

        return has
    
    def addClient(self, client):
        log.info('Clients::addClient')
        log.debug(client)
        self.__checkClientInstance(client)
        
        scope = client.user.id
        if not self.clients.has_key(scope):
            self.clients[scope] = []
            
        self.clients.get(scope).append(client)
        
        log.debug(self.clients)
    
    def removeClient(self, client):
        log.info('Clients::removeClient')
        log.debug(client)
        self.__checkClientInstance(client)
        
        if self.hasClient(client):
            scope = client.user.id
            self.clients.get(scope).remove(client)
            if len(self.clients.get(scope)) == 0:
                del self.clients[scope]
    
        log.debug(self.clients)
    
    def getClients(self, scope):
        log.info('Clients::getClients')
        log.debug(scope)
        if self.clients.has_key(scope):
            return self.clients.get(scope)
        
        return None
