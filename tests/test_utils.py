import unittest
import os
from vendors.utils import File, Datetime
import json
import re

class TestUtils(unittest.TestCase):
    
    def testDatetime_str_to_utc(self):
        
        #print '/'.join(re.compile(r".{1}", re.DOTALL).findall('some123456789client0987654321hash'))
        utc = Datetime.str_to_utc("2010-10-10T10:10:10")
        self.assertEqual(str(utc), '2010-10-10 10:10:10')
    
    def testFileCreate(self):
        print 'testCreate'
        
        dirname = './tmp/testdir1/testdir2'
        file = 'file.txt'
        path = dirname + '/' + file
        
        data = {
            'path': 'files:folder/sub1/test.txt',
            'modified': '17-09-2010 10:10:10', 
            'size': 2388, 
            'hash': '---a1729bc110c---',
        }
        File.create(path, json.dumps(data))
        
        self.assertEqual(os.path.isfile(path), True)
        self.assertEqual(os.path.exists(dirname), True)
        
        os.remove(path)
        self.assertEqual(os.path.isfile(path), False)
        
        os.removedirs(dirname)
        self.assertEqual(os.path.exists(dirname), False)
