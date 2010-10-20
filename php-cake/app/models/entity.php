<?php
class Entity extends AppModel {
	var $name = 'Entity';
	
	var $belongsTo = array(
		'Transaction' => array(
			'className' => 'Transaction',
			'foreignKey' => 'entity_id',
			'dependent' => false,
		),
	);
}
?>