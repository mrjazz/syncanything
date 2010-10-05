import MySQLdb
import MySQLdb.cursors
import sys

from vendors.ObjectsManager import Singleton

import os

from config.loggger import Logger
log = Logger.get("MySQL")

import ConfigParser
config = ConfigParser.ConfigParser()
config.read(os.curdir + "/config/core.cfg")

class DboMySQL(object):
    __metaclass__ = Singleton
    
    def __init__(self):
        log.info('DboMySQL::__init__')
        self.connected = False
        self.connection = None
        self.connect()
    
    def connect(self):
        log.info('DboMySQL::connect')
        try:
            self.connection = MySQLdb.connect(host = config.get("database", "host"), user = config.get("database", "login"), passwd = config.get("database", "password"), db = config.get("database", "database"), cursorclass = MySQLdb.cursors.DictCursor, use_unicode = config.get("database", "unicode"))
            self.connected = True
        except MySQLdb.Error, e:
            print "Error %d: %s" % (e.args[0], e.args[1])
            sys.exit(1)        
            
        log.info('Connected: %s', self.connected)
            
        return self.connected

    def disconnect(self):
        log.info('DboMySQL::disconnect')
        
        if self.connection.close():
            self.connected = False
        
        log.info('Connected: %s', self.connected)
        return self.connected
    
    def query(self, sql):
        log.info('DboMySQL::query %s' % sql)
        
        data = None
        try:
            cursor = self.connection.cursor()
            cursor.execute(sql)
            #data = cursor.fetchone()
            data = cursor.fetchall()
            cursor.close()
        except MySQLdb.Error, e:
            log.critical("Error %d: %s" % (e.args[0], e.args[1]))
            
        log.debug(data)
        return data
    
    def update(self, sql):
        log.info('DboMySQL::update %s' % sql)
        
        rowcount = 0
        try:
            cursor = self.connection.cursor()
            cursor.execute(sql)
            rowcount = cursor.rowcount
            cursor.close()
        except MySQLdb.Error, e:
            log.critical("Error %d: %s" % (e.args[0], e.args[1]))
            
        log.debug(rowcount)
        return rowcount
    
    def insert(self, sql):
        log.info('DboMySQL::insert %s' % sql)
        
        lastrowid = None
        try:
            cursor = self.connection.cursor()
            cursor.execute(sql)
            lastrowid = cursor.lastrowid 
            cursor.close()
        except MySQLdb.Error, e:
            log.critical("Error %d: %s" % (e.args[0], e.args[1]))
            
        log.debug('Last insert id: %s' % lastrowid)
        return lastrowid