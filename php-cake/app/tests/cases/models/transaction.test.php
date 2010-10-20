<?php
/* Transaction Test cases generated on: 2010-09-23 13:09:41 : 1285254281*/
App::import('Model', 'Transaction');

class TransactionTestCase extends CakeTestCase {
	var $useDbConfig = 'test_sync_any_db';
	var $dropTables = false;
	var $fixtures = array('app.transaction', 'app.entity');

	function startTest() {
		$this->Transaction =& ClassRegistry::init('Transaction');
	}

	function testGetUnfinishedByTicket() {
		$ticket = '0123654789';
		$result = $this->Transaction->getUnfinishedByTicket($ticket);

		$this->assertTrue(!empty($result));
	}

		function endTest() {
		unset($this->Transaction);
		ClassRegistry::flush();
	}
	
}
?>