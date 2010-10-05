from twisted.enterprise import util as dbutil

from config.loggger import Logger
import string
log = Logger.get("Model")

class AppModel:
    
    def __init__(self):
        self.table = None
        self._fields = {}
    
    def _getFields(self):
        rows = self.dbconn.query("""
            SHOW COLUMNS FROM %s
            """ % (self.table))
        
        self._fields = {}
        if not rows is None:
            for row in rows:
                self._fields[row['Field']] = row['Type'].split('(')[0]
                if self._fields[row['Field']] == 'datetime':
                    #self._fields[row['Field']] = 'timestamp'
                    dbutil.dbTypeMap['datetime'] = dbutil.USEQUOTE
        
        return self._fields

    def _quote(self, fields, fld = None):
        quoted_fields = fields

        if type(fields) is dict:
            quoted_fields = {}
            for field in fields:
                if self._fields.has_key(field) is True:
                    quoted_fields[field] = dbutil.quote(fields[field], self._fields.get(field))
                else:
                    log.error('Cannot quote sql param:" %s. It was be ignored!' % field)
        elif type(fields) is list:
            quoted_fields = []
            for fld_value in fields:
                if self._fields.has_key(fld) is True:
                    quoted_fields.append(dbutil.quote(fld_value, self._fields.get(fld)))
                else:
                    log.error('Cannot quote sql param:" %s. It was be ignored!' % fld)
        else:
            quoted_fields = dbutil.quote(str(fields), self._fields.get(fld))

        return quoted_fields