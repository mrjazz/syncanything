<?php
App::import('Core', 'CakeSocket');

class ServicesController extends AppController {

	var $name = 'Services';
	var $helpers = array('Html');
	var $uses = array('Transaction');

	function beforeFilter() {
		//$this->layout = '';
		//$this->render(false);
		parent::beforeFilter();
	}
	
	function index() {
		/*
		$delimiter = "\r\n";
		
		$this->Socket = new CakeSocket(array(
			//'host' => 'syncany.evolver.org.ua',
			'host' => 'localhost',
			'port' => 843,
			'request' => array(
				'uri' => array(
					'scheme' => 'https'
				)
			)
		));
		
		$this->Socket->connect();
		
		var_dump($this->Socket->connected);
		if ($this->Socket->connected) {
			
			$responce = array(
				'call' => 'updateEntity',
				'ticket' => "8d59ffdc16c7ae404952973280d6145e",
				'user_id' => 2,
        		'client_id' => 81
			);

			$this->Socket->write(json_encode($responce) . $delimiter);
		}
		
		$this->Socket->disconnect();
		*/
	}
	
	private function setHeader($code) {
		$protocol = $_SERVER["SERVER_PROTOCOL"];
		switch ($code) {
			case '404':
				$h = $protocol . " 404 Not Found";
				break;
			case '200':
				$h = $protocol . " 200 OK";
				break;
			default:
				trigger_error('Undefined header code: ' . $code, E_USER_ERROR);
				break;
		}
		
		header($h);
	}
	
	/**
	 * Create folder or empty fiel by ticket
	 * 
	 * @param $ticket
	 */
	function create($ticket) {
		$this->layout = '';
		$this->render(false);
		
		$result = false;
		$transaction = $this->Transaction->getUnfinishedByTicket($ticket);
		if (isset($transaction['Transaction']) && isset($transaction['Entity'])) {
			$destPath = $transaction['Entity']['stored'] . strtolower($transaction['Entity']['hash']);
			
			$destFolder = $transaction['Entity']['stored'];
			$destPath = $transaction['Entity']['stored'] . strtolower($transaction['Entity']['hash']);
			
			$result = is_dir($destFolder) && is_writeable($destFolder);
			if(!$result) {
				$folder = new Folder($destFolder);
				$result = $folder->create($destFolder, STORAGE_FOLDERS_MOD);
			}

			if ($result) {
				$file = new File($destPath, false, STORAGE_FILES_MOD);
				$result = $file->create();
				var_dump($result);
				$file->close();
			}
		}
		
		if ($result) {
			//notify by socket result
			$this->Transaction->finish($ticket);
			
			if ($this->inTestMode()) {
				return '200'; 
			} else {
				$this->setHeader('200');
			}					
		} else {
			if ($this->inTestMode()) {
				return '404'; 
			} else {
				$this->setHeader('404');
			}
		}
	}
	
	/**
	 * Upload file by client
	 * 
	 * @param $ticket
	 */
	function upload($ticket) {
		$this->layout = '';
		$this->render(false);
		
		$result = false;
		if (!empty($this->params['form'])) {
			$request = $this->params['form'];
			if ($this->__uploadByTicket($ticket, $request)) {
				//$this->cakeError('error404');
				$result = true;
			}			
		}
		
		if ($result) {
			//notify by socket result
			$this->Transaction->finish($ticket);
			
			if ($this->inTestMode()) {
				return '200'; 
			} else {
				$this->setHeader('200');
			}					
		} else {
			if ($this->inTestMode()) {
				return '404'; 
			} else {
				$this->setHeader('404');
			}
		}
		
	}

	/**
	 * Upload file from web frontend
	 */
	function web_upload() {
		$request = $this->params['form'];
		
		if (!empty($this->data)) {
			/*
			STORAGE_PATH
			
			if ($this->__copyUploadedFile($sourceFile, $destFile)) {
				$this->Transaction->finish($ticket);
				return true;
			}
			*/
		}
	}
	
	private function __uploadByTicket($ticket, $request) {
		// only for test without ngnix
		if (isset($request['entity']['tmp_name'])) {
			$request['entity_path'] = $request['entity']['tmp_name'];
		}
		
		$transaction = $this->Transaction->getUnfinishedByTicket($ticket);
		if (isset($transaction['Transaction']) && isset($transaction['Entity'])) {
			$storageFolder = $transaction['Entity']['stored'];
			$storageFile = strtolower($transaction['Entity']['hash']);
			$destFile = $storageFolder . $storageFile; 
			
			if (!empty($request['entity_path'])) {
				$sourceFile = $request['entity_path'];
				
				if ($this->__copyUploadedFile($sourceFile, $destFile)) {
					$this->Transaction->finish($ticket);
					
					//notify by socket result
					
					return true;
				}
			}
		}

		return false;
	}
	
	private function __copyUploadedFile($source, $dest) {
		$destFolder = str_replace(array('\\', '/'), DS, dirname($dest));

		$result = is_dir($destFolder) && is_writeable($destFolder);
		if(!$result) {
			$folder = new Folder($destFolder);
			$result = $folder->create($destFolder, STORAGE_FOLDERS_MOD);
		}
		
		if ($result) {
			$file = new File($source);
			$result = $file->copy($dest);
			$file->close();
		}

		return $result;
	}
	
	function download($ticket) {
		$this->layout = '';
		$this->render(false);
	}
	
	function delete($ticket) {
		$this->layout = '';
		$this->render(false);
		$this->setHeader('200');
	}
}
?>