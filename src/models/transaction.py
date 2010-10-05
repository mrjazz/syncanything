from twisted.enterprise import util as dbutil
import datetime

from dbo.DboMySQL import DboMySQL

from app_model import AppModel

from config.loggger import Logger
from vendors.utils import Datetime
log = Logger.get("Model")

class Transaction(AppModel):
    def __init__(self):
        log.info('Transaction::__init__')
        
        self.dbconn = DboMySQL()
        self.table = 'transactions'
        self._fields = self._getFields()
    
    def create(self, data):
        log.info('Transaction::create')
        log.debug(data)
        
        data = self._quote(data)
        return self.dbconn.insert("""
            INSERT INTO %s
                (`user_id`,
                `entity_id`,
                `client_id`,
                `ticket`,
                `started`,
                `action`,
                `created`,
                `modified`)
            VALUES
                (%s, 
                %s, 
                %s,
                %s,
                NOW(),
                %s,
                NOW(), 
                NOW())
        """ % (
               self.table,
               data.get('user_id'), 
               data.get('entity_id'),
               data.get('client_id'),
               data.get('ticket'),
               data.get('action')
            )
        )
    
    def removeUncompleted(self, user_id, client_id):
        log.info('Transaction::removeUncompleted')
        
        data = {
            'user_id': user_id, 
            'client_id': client_id
        }
        data = self._quote(data)
        log.debug(data)
        return self.dbconn.query("""
            DELETE Transaction, Entity
            FROM transactions as Transaction
                 LEFT JOIN entities as Entity ON Entity.`transaction_id` = Transaction.id
            WHERE
                Entity.user_id = %s AND
                Transaction.user_id = %s AND
                Transaction.client_id = %s AND
                NOW() > DATE_ADD(Transaction.started, INTERVAL 1 DAY) AND
                Transaction.finished IS NULL
            """ % (
                   data.get('user_id'),
                   data.get('user_id'),
                   data.get('client_id')
                   )
            )
        
    
    def getUnCompleted(self, user_id, client_id):
        log.info('Transaction::getUnCompleted')
        
        data = {
            'user_id': user_id, 
            'client_id': client_id
        }
        data = self._quote(data)
        log.debug(data)

        rows = self.dbconn.query("""
            SELECT 
                Entity.id as 'Entity.id',
                Entity.user_id as 'Entity.user_id',
                Entity.transaction_id as 'Entity.transaction_id',
                Entity.path as 'Entity.path',
                Entity.size as 'Entity.size',
                Entity.filedate as 'Entity.filedate',
                Entity.hash as 'Entity.hash',
                Entity.stored as 'Entity.stored',
                Entity.created as 'Entity.created',
                Entity.modified as 'Entity.modified',
                Entity.deleted as 'Entity.deleted',
                Transaction.user_id as 'Transaction.user_id',
                Transaction.client_id as 'Transaction.client_id',
                Transaction.ticket as 'Transaction.ticket',
                Transaction.started as 'Transaction.started',
                Transaction.finished as 'Transaction.finished',
                Transaction.action as 'Transaction.action',
                Transaction.created as 'Transaction.created',
                Transaction.modified as 'Transaction.modified',
                Transaction.deleted as 'Transaction.deleted'
             FROM %s as Transaction
             LEFT JOIN entities as Entity ON Entity.`transaction_id` = Transaction.id
             WHERE
                 Entity.user_id = %s AND
                 Transaction.user_id = %s AND
                 Transaction.client_id = %s AND
                 #NOW() < DATE_ADD(Transaction.started, INTERVAL 1 DAY) AND
                 Transaction.finished IS NULL
             #GROUP BY Transaction.entity_id
             #GROUP BY Entity.path
             ORDER BY Transaction.started ASC
            """ % (
                   self.table,
                   data.get('user_id'),
                   data.get('user_id'),
                   data.get('client_id')
                   )
            )
        
        return rows 
    
    def prepareToClient(self, rows):
        log.info('Transaction::prepareToClient')
        log.debug(rows)
        
        entities = []
        for row in rows:
            try:
                row['Entity.size'] = int(row['Entity.size'])
            except Exception, e:
                row['Entity.size'] = 0
            
            entity = {
                'path': row['Entity.path'], 
                'modified': Datetime.utcformat_datetime(row['Entity.filedate']),
                'size':row['Entity.size'], 
                'hash': row['Entity.hash'],
                'action': self.__actionToStr(row['Transaction.action']),
                'ticket': row['Transaction.ticket']
            }
            entities.append(entity)
        
        return entities

    # action: int (0 - upload, 1 - download, 2 - delete)
    def __actionToStr(self, action):
        log.info('Transaction::__actionToStr')
        log.debug(action)
        
        result = None
        if action == 0:
            result = 'upload'
        elif action == 1: 
            result = 'download'
        elif action == 2:
            result = 'delete'

        return result
    
    def findByUserTickets(self, user_id, client_id, tickets):
        log.info('Transaction::findByUserTickets')
        
        q_tickets = self._quote(tickets, 'ticket')
        
        data = {
            'user_id': user_id, 
            'client_id': client_id
        }
        data = self._quote(data)
        log.debug(data)
        
        rows = self.dbconn.query("""
            SELECT 
                Entity.id as 'Entity.id',
                Entity.user_id as 'Entity.user_id',
                Entity.transaction_id as 'Entity.transaction_id',
                Entity.path as 'Entity.path',
                Entity.size as 'Entity.size',
                Entity.filedate as 'Entity.filedate',
                Entity.hash as 'Entity.hash',
                Entity.stored as 'Entity.stored',
                Entity.created as 'Entity.created',
                Entity.modified as 'Entity.modified',
                Entity.deleted as 'Entity.deleted',
                Transaction.user_id as 'Transaction.user_id',
                Transaction.client_id as 'Transaction.client_id',
                Transaction.ticket as 'Transaction.ticket',
                Transaction.started as 'Transaction.started',
                Transaction.finished as 'Transaction.finished',
                Transaction.action as 'Transaction.action',
                Transaction.created as 'Transaction.created',
                Transaction.modified as 'Transaction.modified',
                Transaction.deleted as 'Transaction.deleted'
             FROM %s as Transaction
             LEFT JOIN entities as Entity ON Entity.`transaction_id` = Transaction.id
             WHERE
                 Entity.user_id = %s AND
                 Transaction.user_id = %s AND
                 Transaction.client_id = %s AND
                 Transaction.ticket IN (%s)
             #GROUP BY Transaction.entity_id
             #GROUP BY Entity.path
             ORDER BY Transaction.started ASC
            """ % (
                   self.table,
                   data.get('user_id'),
                   data.get('user_id'),
                   data.get('client_id'),
                   ", ".join(q_tickets)))
        
        return rows
    
    def getLastSyncedDate(self, user_id, client_id):
        log.info('Transaction::getLastSyncedDate')
        
        data = {
            'user_id': user_id, 
            'client_id': client_id
        }
        data = self._quote(data)
        log.debug(data)
        rows = self.dbconn.query("""
            SELECT 
                finished 
            FROM 
                %s 
            WHERE 
                transactions.user_id = %s AND
                transactions.client_id = %s AND
                transactions.finished IS NOT NULL
            ORDER BY finished DESC 
            LIMIT 1
            """ % (
                   self.table,
                   data.get('user_id'),
                   data.get('client_id')
                   )
            )
        
        if not rows is None and len(rows) > 0:
            return rows[0]['finished']
        
        return None
    
    def getSkiped(self, data):
        log.info('Transaction::getSkiped')
        
        finished = data.pop('finished')
        if finished is None:
            finished = 'TRUE'
        else:
            finished = 'Transaction.finished > %s' % self._quote(finished, 'finished')
        
        data = self._quote(data)
        log.debug(data)

        rows = self.dbconn.query("""
            SELECT 
                Entity.id as 'Entity.id',
                Entity.user_id as 'Entity.user_id',
                Entity.transaction_id as 'Entity.transaction_id',
                Entity.path as 'Entity.path',
                Entity.size as 'Entity.size',
                Entity.filedate as 'Entity.filedate',
                Entity.hash as 'Entity.hash',
                Entity.stored as 'Entity.stored',
                Entity.created as 'Entity.created',
                Entity.modified as 'Entity.modified',
                Entity.deleted as 'Entity.deleted',
                Transaction.user_id as 'Transaction.user_id',
                Transaction.client_id as 'Transaction.client_id',
                Transaction.ticket as 'Transaction.ticket',
                Transaction.started as 'Transaction.started',
                Transaction.finished as 'Transaction.finished',
                Transaction.action as 'Transaction.action',
                Transaction.created as 'Transaction.created',
                Transaction.modified as 'Transaction.modified',
                Transaction.deleted as 'Transaction.deleted'
             FROM %s as Transaction
             LEFT JOIN entities as Entity ON Entity.`transaction_id` = Transaction.id
             WHERE
                 Entity.user_id = %s AND
                 Transaction.user_id = %s AND
                 Transaction.client_id <> %s AND
                 Transaction.finished IS NOT NULL AND
                 %s
             #GROUP BY Transaction.entity_id
             GROUP BY Entity.path
             ORDER BY Transaction.started DESC
            """ % (
                   self.table,
                   data.get('user_id'), 
                   data.get('user_id'),
                   data.get('client_id'),
                   finished
                   )
            )
        
        return rows
    