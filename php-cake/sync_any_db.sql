-- MySQL dump 10.11
--
-- Host: localhost    Database: sync_any_db
-- ------------------------------------------------------
-- Server version	5.0.77-community-nt

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `clients` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `client_hash` varchar(255) default NULL,
  `client` varchar(255) default NULL,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `is_deleted` enum('YES','NO') default 'NO',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=84 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (81,2,'some123456789client0987654321hash','WinDesktop','2010-09-22 12:17:22','2010-09-22 12:17:22',''),(83,2,'some123456789client0987654321hash','WinDesktop','2010-09-27 16:25:42','2010-09-27 16:25:42','NO');
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entities`
--

DROP TABLE IF EXISTS `entities`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `entities` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `transaction_id` int(11) default NULL,
  `path` text,
  `is_folder` enum('YES','NO') default 'NO',
  `size` int(11) default NULL,
  `filedate` datetime default NULL,
  `hash` varchar(255) default NULL,
  `stored` text,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `is_deleted` enum('YES','NO') default 'NO',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=900 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `entities`
--

LOCK TABLES `entities` WRITE;
/*!40000 ALTER TABLE `entities` DISABLE KEYS */;
INSERT INTO `entities` VALUES (873,2,867,'files:folder/tests/test.txt','NO',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(872,2,866,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(874,2,868,'files:folder/tests/tEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(875,2,869,'files:folder/tests/removedtEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(876,2,870,'files:folder/tests/removedTEST.txt','NO',0,'2010-10-11 10:10:10','odn348fmeice','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(877,2,871,'files:folder/tests/123/4567/89000/test2.txt','NO',160000,'2010-10-12 10:10:10','mxodnmd83nmd','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(878,2,872,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(879,2,873,'files:folder/tests/test.txt','NO',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(880,2,874,'files:folder/tests/tEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(881,2,875,'files:folder/tests/removedtEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(882,2,876,'files:folder/tests/removedTEST.txt','NO',0,'2010-10-11 10:10:10','odn348fmeice','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(883,2,877,'files:folder/tests/123/4567/89000/test2.txt','NO',160000,'2010-10-12 10:10:10','mxodnmd83nmd','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(884,2,878,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:39:55','2010-09-27 16:39:55','NO'),(885,2,879,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:39:55','2010-09-27 16:39:55','NO'),(886,2,880,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:41:14','2010-09-27 16:41:14','NO'),(887,2,881,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:41:14','2010-09-27 16:41:14','NO'),(888,2,882,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(889,2,883,'files:folder/tests/test.txt','NO',0,'2010-10-11 10:10:10','d6fe1d0be6347b8ef2427fa629c04485','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(890,2,884,'files:folder/tests/tEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(891,2,885,'files:folder/tests/removedtEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(892,2,886,'files:folder/tests/removedTEST.txt','NO',0,'2010-10-11 10:10:10','odn348fmeice','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(893,2,887,'files:folder/tests/123/4567/89000/test2.txt','NO',160000,'2010-10-12 10:10:10','mxodnmd83nmd','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(894,2,888,'files:folder/test.txt','NO',2388,'2010-10-10 10:10:10','a1729bc110c','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(895,2,889,'files:folder/tests/test.txt','NO',0,'2010-10-11 10:10:10','d6fe1d0be6347b8ef2427fa629c04485','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(896,2,890,'files:folder/tests/tEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(897,2,891,'files:folder/tests/removedtEsTtxt','YES',0,'2010-10-11 10:10:10','','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\folders','2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(898,2,892,'files:folder/tests/removedTEST.txt','NO',0,'2010-10-11 10:10:10','odn348fmeice','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(899,2,893,'files:folder/tests/123/4567/89000/test2.txt','NO',160000,'2010-10-12 10:10:10','mxodnmd83nmd','D:\\localhost\\www\\python_project\\SyncAny\\src\\storage\\files','2010-09-27 16:42:57','2010-09-27 16:42:57','NO');
/*!40000 ALTER TABLE `entities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `logs` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `client_id` int(11) default NULL,
  `level` int(11) default NULL,
  `details` text,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `is_deleted` enum('YES','NO') default 'NO',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `entity_id` int(11) default NULL,
  `client_id` int(11) default NULL,
  `ticket` varchar(255) default NULL,
  `started` datetime default NULL,
  `finished` datetime default NULL,
  `action` int(11) default NULL,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `is_deleted` enum('YES','NO') default 'NO',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=894 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (866,2,872,83,'9419d8fc75111f3360b1ee159cfc7513','2010-09-27 16:37:57',NULL,1,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(867,2,873,83,'837b26140cc86abbbe777f9694b09ce4','2010-09-27 16:37:57',NULL,1,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(868,2,874,83,'f34ce2e5c7b31f507df8ca83963f356f','2010-09-27 16:37:57',NULL,0,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(869,2,875,83,'ea0dae0b21759b4ef07a41e500fd53dd','2010-09-27 16:37:57',NULL,3,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(870,2,876,83,'7983d425d91096507f534e2f9158522e','2010-09-27 16:37:57',NULL,3,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(871,2,877,83,'f39f2ec0eb79f12bb0374ee4b12ddd19','2010-09-27 16:37:57',NULL,1,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(872,2,878,83,'a631f4fe0c2bfdd10c4db52069f24067','2010-09-27 16:37:57',NULL,1,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(873,2,879,83,'438e3764bd1a561e8f602d72bdb81d3f','2010-09-27 16:37:57',NULL,1,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(874,2,880,83,'3bb1bb9d6835b4cd59371f9cb7b29d7c','2010-09-27 16:37:57',NULL,0,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(875,2,881,83,'e9abac3910bc998a771a3cba7e02633c','2010-09-27 16:37:57',NULL,3,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(876,2,882,83,'3545b4b729b46e38b05873d9e4e6ee9d','2010-09-27 16:37:57',NULL,3,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(877,2,883,83,'61201076400448a559136026219e5ea5','2010-09-27 16:37:57',NULL,1,'2010-09-27 16:37:57','2010-09-27 16:37:57','NO'),(878,2,884,83,'61f96dad32a5749a67934ea931b8b530','2010-09-27 16:39:55',NULL,1,'2010-09-27 16:39:55','2010-09-27 16:39:55','NO'),(879,2,885,83,'ffa1e08f226d124ef547844400e2114b','2010-09-27 16:39:55',NULL,1,'2010-09-27 16:39:55','2010-09-27 16:39:55','NO'),(880,2,886,83,'baecc6d836c95f0d133fcd4cbd5d7024','2010-09-27 16:41:14',NULL,1,'2010-09-27 16:41:14','2010-09-27 16:41:14','NO'),(881,2,887,83,'b491c95d8331ac8e3aa92eb725ac2ec8','2010-09-27 16:41:14',NULL,1,'2010-09-27 16:41:14','2010-09-27 16:41:14','NO'),(882,2,888,83,'f00c7caf9dbe8c2e1a49fb625fce10d9','2010-09-27 16:42:56',NULL,1,'2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(883,2,889,83,'d3361aa4f6ad5819a845da750cdd33b0','2010-09-27 16:42:56',NULL,1,'2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(884,2,890,83,'a291400022ac428f8485931060b5e50e','2010-09-27 16:42:56',NULL,0,'2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(885,2,891,83,'a17dbaaef3623f9a4903291f5295834b','2010-09-27 16:42:56',NULL,3,'2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(886,2,892,83,'ea13a88985fca8365f9f1f20cba2fcde','2010-09-27 16:42:56',NULL,3,'2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(887,2,893,83,'d2fc5012c0feca485bb876150780d76b','2010-09-27 16:42:56',NULL,1,'2010-09-27 16:42:56','2010-09-27 16:42:56','NO'),(888,2,894,83,'a075a19bef321f657c04f83e45d97076','2010-09-27 16:42:57',NULL,1,'2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(889,2,895,83,'67e4629e550349717e870fb657b0d80f','2010-09-27 16:42:57',NULL,1,'2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(890,2,896,83,'fb6bdee73e8f992b570e3331a4452055','2010-09-27 16:42:57',NULL,0,'2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(891,2,897,83,'787f242a0ed9e54e70ac6c73f3c2b4e1','2010-09-27 16:42:57',NULL,3,'2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(892,2,898,83,'a56ed6d9f512ca87524220f0e0f6aee5','2010-09-27 16:42:57',NULL,3,'2010-09-27 16:42:57','2010-09-27 16:42:57','NO'),(893,2,899,83,'6c67b873cc3fb7ce92014ae05812f816','2010-09-27 16:42:57',NULL,1,'2010-09-27 16:42:57','2010-09-27 16:42:57','NO');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `first_name` varchar(255) default NULL,
  `last_name` varchar(255) default NULL,
  `password` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `plan` varchar(25) default NULL,
  `created` datetime default NULL,
  `modified` datetime default NULL,
  `is_deleted` enum('YES','NO') default 'NO',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'George','Cloony','hash_password','cloony@mail.hollywood.com','free','2010-09-17 19:11:51','2010-09-17 19:11:52','NO');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-09-27 13:59:51
