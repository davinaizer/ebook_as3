/**
 * Created by Naizer on 02/10/2015.
 */
package com.unboxds.ebook.model.vo
{
	public class NavVO
	{
		private var _maxPage:int;
		private var _maxModule:int;
		private var _currentPage:int;
		private var _currentModule:int;

		public function NavVO()
		{
		}

		public function get maxPage():int
		{
			return _maxPage;
		}

		public function set maxPage(value:int):void
		{
			_maxPage = value;
		}

		public function get maxModule():int
		{
			return _maxModule;
		}

		public function set maxModule(value:int):void
		{
			_maxModule = value;
		}

		public function get currentPage():int
		{
			return _currentPage;
		}

		public function set currentPage(value:int):void
		{
			_currentPage = value;
		}

		public function get currentModule():int
		{
			return _currentModule;
		}

		public function set currentModule(value:int):void
		{
			_currentModule = value;
		}
	}
}
