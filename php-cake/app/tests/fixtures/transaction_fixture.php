<?php
/* Transaction Fixture generated on: 2010-09-23 13:09:41 : 1285254281 */
class TransactionFixture extends CakeTestFixture {
	var $name = 'Transaction';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'user_id' => array('type' => 'integer', 'null' => true, 'default' => NULL),
		'entity_id' => array('type' => 'integer', 'null' => true, 'default' => NULL),
		'client_id' => array('type' => 'integer', 'null' => true, 'default' => NULL),
		'ticket' => array('type' => 'string', 'null' => true, 'default' => NULL, 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
		'started' => array('type' => 'datetime', 'null' => true, 'default' => NULL),
		'finished' => array('type' => 'datetime', 'null' => true, 'default' => NULL),
		'action' => array('type' => 'integer', 'null' => true, 'default' => NULL),
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
			'entity_id' => 1,
			'client_id' => 1,
			'ticket' => '0123654789',
			'started' => '2010-09-23 13:04:41',
			'finished' => null,
			'action' => 1,
			'created' => '2010-09-23 13:04:41',
			'modified' => '2010-09-23 13:04:41',
			'is_deleted' => 'NO'
		),
		array( //test upload method controller services
			'id' => 2,
			'user_id' => 1,
			'entity_id' => 2,
			'client_id' => 1,
			'ticket' => 'someticket1234',
			'started' => '2010-09-23 13:04:41',
			'finished' => null,
			'action' => 1,
			'created' => '2010-09-23 13:04:41',
			'modified' => '2010-09-23 13:04:41',
			'is_deleted' => 'NO'
		),
		array( //test create folder
			'id' => 3,
			'user_id' => 1,
			'entity_id' => 3,
			'client_id' => 1,
			'ticket' => 'ticketCreateFolder',
			'started' => '2010-09-23 13:04:41',
			'finished' => null,
			'action' => 0,
			'created' => '2010-09-23 13:04:41',
			'modified' => '2010-09-23 13:04:41',
			'is_deleted' => 'NO'
		),
		array( //test create file
			'id' => 4,
			'user_id' => 1,
			'entity_id' => 4,
			'client_id' => 1,
			'ticket' => 'ticketCreateFile',
			'started' => '2010-09-23 13:04:41',
			'finished' => null,
			'action' => 0,
			'created' => '2010-09-23 13:04:41',
			'modified' => '2010-09-23 13:04:41',
			'is_deleted' => 'NO'
		),
	);
}
?>