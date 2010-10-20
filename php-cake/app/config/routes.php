<?php
/**
 * Routes configuration
 *
 * In this file, you set up routes to your controllers and their actions.
 * Routes are very important mechanism that allows you to freely connect
 * different urls to chosen controllers and their actions (functions).
 *
 * PHP versions 4 and 5
 *
 * CakePHP(tm) : Rapid Development Framework (http://cakephp.org)
 * Copyright 2005-2010, Cake Software Foundation, Inc. (http://cakefoundation.org)
 *
 * Licensed under The MIT License
 * Redistributions of files must retain the above copyright notice.
 *
 * @copyright     Copyright 2005-2010, Cake Software Foundation, Inc. (http://cakefoundation.org)
 * @link          http://cakephp.org CakePHP(tm) Project
 * @package       cake
 * @subpackage    cake.app.config
 * @since         CakePHP(tm) v 0.2.9
 * @license       MIT License (http://www.opensource.org/licenses/mit-license.php)
 */
/**
 * Here, we are connecting '/' (base path) to controller called 'Pages',
 * its action called 'display', and we pass a param to select the view file
 * to use (in this case, /app/views/pages/home.ctp)...
 */
	Router::connect('/', array('controller' => 'pages', 'action' => 'display', 'home'));
/**
 * ...and connect the rest of 'Pages' controller's urls.
 */
	
	Router::connect('/services/', array('controller' => 'services', 'action' => 'index'));
	Router::connect('/services/index', array('controller' => 'services', 'action' => 'index'));
	//Router::connect('/services/upload', array('controller' => 'services', 'action' => 'web_upload'));
	
	Router::connect('/create/:ticket', array('controller' => 'services', 'action' => 'create'), array('pass' => array('ticket'), 'ticket' => '[0-9a-zA-Z]+'));
	Router::connect('/upload/:ticket', array('controller' => 'services', 'action' => 'upload'), array('pass' => array('ticket'), 'ticket' => '[0-9a-zA-Z]+'));
	Router::connect('/download/:ticket', array('controller' => 'services', 'action' => 'download'), array('pass' => array('ticket'), 'ticket' => '[0-9a-zA-Z]+'));
	Router::connect('/delete/:ticket', array('controller' => 'services', 'action' => 'delete'), array('pass' => array('ticket'), 'ticket' => '[0-9a-zA-Z]+'));

	Router::connect('/services/create', array('controller' => 'services', 'action' => 'web_create'));
	Router::connect('/services/upload', array('controller' => 'services', 'action' => 'web_upload'));
	Router::connect('/services/download', array('controller' => 'services', 'action' => 'web_download'));
	Router::connect('/services/delete', array('controller' => 'services', 'action' => 'web_delete'));

	Router::connect('/pages/*', array('controller' => 'pages', 'action' => 'display'));