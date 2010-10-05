import os
import sys
sys.path.append(os.getcwd())

from twisted.application import internet, service
from sync_any import SyncAnyFactory

SyncAny = SyncAnyFactory()
application = service.Application('Sync Any')
gameService = internet.TCPServer(2323, SyncAny)
gameService.setServiceParent(application)