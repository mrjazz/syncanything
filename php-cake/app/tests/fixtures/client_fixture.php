<?php
/* Client Fixture generated on: 2010-09-23 13:09:09 : 1285254249 */
class ClientFixture extends CakeTestFixture {
	var $name = 'Client';

	var $fields = array(
		'id' => array('type' => 'integer', 'null' => false, 'default' => NULL, 'key' => 'primary'),
		'user_id' => array('type' => 'integer', 'null' => true, 'default' => NULL),
		'client_hash' => array('type' => 'string', 'null' => true, 'default' => NULL, 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
		'client' => array('type' => 'string', 'null' => true, 'default' => NULL, 'collate' => 'utf8_general_ci', 'charset' => 'utf8'),
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
			'client_hash' => 'Lorem ipsum dolor sit amet',
			'client' => 'Lorem ipsum dolor sit amet',
			'created' => '2010-09-23 13:04:09',
			'modified' => '2010-09-23 13:04:09',
			'is_deleted' => 'NO'
		),
	);
}
?>