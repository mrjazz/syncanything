<?php
class Transaction extends AppModel {
	var $name = 'Transaction';
	
	var $hasOne = array(
		'Entity' => array(
			'className' => 'Entity',
			'foreignKey' => 'transaction_id',
			'dependent' => false,
		),
	);
	
	function getUnfinishedByTicket($ticket) {
		return $this->find('first', array(
			'conditions' => array(
				'Transaction.ticket' => $ticket,
				'Transaction.finished IS NULL'
			),
			'contain' => array('Entity')
		));
	}
	
	function finish($ticket) {
		return $this->updateAll(
			array('Transaction.finished' => "NOW()"), 
			array('Transaction.ticket' => $ticket)
		);
	}
	
}
?>