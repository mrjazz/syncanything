<?php
class AppController extends Controller {
	function inTestMode() {
		return defined('TEST_CAKE_CORE_INCLUDE_PATH');
	}
}
?>
