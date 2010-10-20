<?php
define('_STORED_', TMP . 'tests' . DS);

/* Entity Fixture generated on: 2010-09-23 13:09:18 : 1285254258 */
class EntityFixture extends CakeTestFixture {
	var $name = 'Entity';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'user_id' => array('type' => 'integer', 'null' => true, 'default' => NULL),
		'transaction_id' => array('type' => 'integer', 'null' => true, 'default' => NULL),
		'path' => array('type' => 'text', 'null' => true, 'default' => NULL, 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
		'is_folder' => array('type' => 'string', 'null' => true, 'default' => 'NO', 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
		'size' => array('type' => 'integer', 'null' => true, 'default' => NULL),
		'filedate' => array('type' => 'datetime', 'null' => true, 'default' => NULL),
		'hash' => array('type' => 'string', 'null' => true, 'default' => NULL, 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
		'stored' => array('type' => 'text', 'null' => true, 'default' => NULL, 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
		'created' => array('type' => 'datetime', 'null' => true, 'default' => NULL),
		'modified' => array('type' => 'datetime', 'null' => true, 'default' => NULL),
		'is_deleted' => array('type' => 'string', 'null' => true, 'default' => 'NO', 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
		'indexes' => array('PRIMARY' => array('column' => 'id', 'unique' => 1)),
		'tableParameters' => array('charset' => 'utf8', 'collate' => 'utf8_general_ci', 'engine' => 'MyISAM')
	);

	var $records = array(
		array(
			'id' => 1,
			'user_id' => 1,
			'transaction_id' => 1,
			'path' => '/some/path/to/folder/file.bin',
			'is_folder' => 'NO', 
			'size' => 1,
			'filedate' => '2010-09-23 13:04:18',
			'hash' => '0doejducv734',
			'stored' => _STORED_,
			'created' => '2010-09-23 13:04:18',
			'modified' => '2010-09-23 13:04:18',
			'is_deleted' => 'NO'
		),
		array( //test upload method controller services
			'id' => 2,
			'user_id' => 1,
			'transaction_id' => 2,
			'path' => '/some/path/to/folder/file.bin',
			'is_folder' => 'NO',
			'size' => 1,
			'filedate' => '2010-09-23 13:04:18',
			'hash' => 'uploadHash',
			'stored' => _STORED_,
			'created' => '2010-09-23 13:04:18',
			'modified' => '2010-09-23 13:04:18',
			'is_deleted' => 'NO'
		),
		array( //used
			'id' => 3,
			'user_id' => 1,
			'transaction_id' => 3,
			'path' => '/some/path/to/create/folder',
			'is_folder' => 'YES',
			'size' => 0,
			'filedate' => '2010-09-23 13:04:18',
			'hash' => 'createFolderHash',
			'stored' => _STORED_,
			'created' => '2010-09-23 13:04:18',
			'modified' => '2010-09-23 13:04:18',
			'is_deleted' => 'NO'
		),
		array( //used
			'id' => 4,
			'user_id' => 1,
			'transaction_id' => 4,
			'path' => '/some/path/to/create/file.f',
			'is_folder' => 'NO',
			'size' => 0,
			'filedate' => '2010-09-23 13:04:18',
			'hash' => 'createFileHash',
			'stored' => _STORED_,
			'created' => '2010-09-23 13:04:18',
			'modified' => '2010-09-23 13:04:18',
			'is_deleted' => 'NO'
		),
	);
}
?>