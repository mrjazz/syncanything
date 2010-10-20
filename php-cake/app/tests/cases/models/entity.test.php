<?php
/* Entity Test cases generated on: 2010-09-23 13:09:18 : 1285254258*/
App::import('Model', 'Entity');

class EntityTestCase extends CakeTestCase {
	var $useDbConfig = 'test_sync_any_db';
	var $fixtures = array('app.entity');
	var $dropTables = false;

	function startTest() {
		$this->Entity =& ClassRegistry::init('Entity');
	}

	function endTest() {
		unset($this->Entity);
		ClassRegistry::flush();
	}

}
?>