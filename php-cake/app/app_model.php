<?php

class AppModel extends Model{
    
    var $actsAs = array('Containable');
    var $catchCount = false;        
    var $catchedRows = false;

	/**
	 * @return DboSource current DboSource for model
	 */
	function getDbSource() {
		return ConnectionManager::getDataSource($this->useDbConfig);
	}

	function del($id = null, $cascade = true) {
		if (is_null($id)) return false;
		if (!is_array($id)) {
			$id = array($id);
		}
		foreach ($id as $id1) {
			$this->save(
				array(
					$this->name => array('id' => $id1, 'is_deleted' => 'YES', 'deleted' => date('Y-m-d H:i:s'))
				),
				false,
				array('is_deleted', 'deleted')
			);
		}
	}
	
	function undel($id = null, $cascade = true) {
		$this->save(
			array(
				$this->name => array('id' => $id, 'is_deleted' => 'NO')
			),
			false,
			array('is_deleted', 'deleted')
		);
	}
	
	function delete($id = null, $cascade = true) {
		return parent::del($id, $cascade);
	}

}

?>