<?php
/* Services Test cases generated on: 2010-09-27 06:09:49 : 1285577809*/
App::import('Controller', 'Services');

class TestServicesController extends ServicesController {
	var $autoRender = false;

	function redirect($url, $status = null, $exit = true) {
		$this->redirectUrl = $url;
	}
}

class ServicesControllerTestCase extends CakeTestCase {
	var $fixtures = array('app.transaction', 'app.entity');

	function startTest() {
		$this->Services =& new TestServicesController();
		$this->Services->constructClasses();
	}

	function endTest() {
		unset($this->Services);
		ClassRegistry::flush();
	}

	function testIndex() {

	}

	function testUploadOK() {
		
		$form = array(
			'entity_path' => __FILE__
		);
		
		$this->dropTables = false;
		$result = $this->testAction('/upload/someticket1234', 
			array(
				'fixturize' => true, 
				'form' => $form, 
				'method' => 'post'
			)
		);
		
		$this->assertEqual($result, '200');
		$file = new File(_STORED_ . 'uploadhash');
		$file->delete();
	}
	
	function testUploadFail() {
		
		$form = array(
			'entity_path' => __FILE__
		);
		
		$this->dropTables = false;
		$result = $this->testAction('/upload/undefinedTicket', 
			array(
				'fixturize' => true, 
				'form' => $form, 
				'method' => 'post'
			)
		);
		
		$this->assertEqual($result, '404');
	}

	function testCreateOK() {
		
		$this->dropTables = false;
		$result = $this->testAction('/create/ticketCreateFolder', 
			array(
				'fixturize' => true, 
			)
		);
		
		$this->assertEqual($result, '200');
		$file = new File(_STORED_ . 'CreateFolderHash');
		$file->delete();
	}
	
	function testCreateFail() {
		
		$this->dropTables = false;
		$result = $this->testAction('/create/ticketCreateFolderFail', 
			array(
				'fixturize' => true, 
			)
		);
		
		$this->assertEqual($result, '404');
	}
	
	function testCreateFileOK() {
		
		$this->dropTables = false;
		$result = $this->testAction('/create/ticketCreateFile', 
			array(
				'fixturize' => true, 
			)
		);
		
		$this->assertEqual($result, '200');
		
		$file = new File(_STORED_ . 'CreateFileHash');
		$file->delete();
	}
	
	function testCreateFileFail() {
		$this->dropTables = false;
		$result = $this->testAction('/create/ticketCreateFileFail', 
			array(
				'fixturize' => true, 
			)
		);
		
		$this->assertEqual($result, '404');
	}
	
	function testWebUpload() {

	}

	function testDownload() {

	}

	function testDelete() {

	}

}
?>