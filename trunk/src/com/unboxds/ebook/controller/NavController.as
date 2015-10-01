﻿package com.unboxds.ebook.controller
{
	import com.unboxds.ebook.EbookApi;
	import com.unboxds.ebook.model.EbookModel;
	import com.unboxds.ebook.model.NavModel;
	import com.unboxds.ebook.model.vo.PageData;
	import com.unboxds.utils.Logger;

	import org.osflash.signals.Signal;

	public class NavController
	{
		private var model:NavModel;

		private var ebook:EbookApi;
		private var status:EbookModel; //TODO Create a NavVo to store data. Eleminate status Class dependecy.

		private var _onChange:Signal;
		private var _xmlData:XML;
		private var _totalModules:uint;
		private var _totalPages:uint;
		private var _modPagesCount:Array;
		private var _navDirection:int;
		private var _onBeforeNextPage:Function;
		private var _onBeforeBackPage:Function;

		public function NavController()
		{
			Logger.log("NavController.NavController");
			onChange = new Signal(PageData);
		}

		public function init():void
		{
			Logger.log("NavController.init");

			model = new NavModel();
			model.parsePages(_xmlData);

			ebook = EbookApi.getInstance();
			status = ebook.getEbookModel();

			_totalModules = model.pages.length;
			_totalPages = model.pageQueue.length;
			_navDirection = 1;

			_modPagesCount = [];
			for (var i:int = 0; i < model.pages.length; i++)
				_modPagesCount.push(model.pages[i].length);

			Logger.log(">>>> Navigation Statistics <<<<");
			Logger.log("	• Total Modules: " + _totalModules);
			Logger.log("	• Total Pages in each module: " + _modPagesCount.join(" | "));
			Logger.log("	• Total Pages: " + _totalPages);
			Logger.log("-------------------");
		}

		public function nextPage():void
		{
			if (_onBeforeNextPage != null)
			{
				Logger.log("NavController.nextPage >> onBeforeNextPage");
				_onBeforeNextPage();
			}
			else
			{
				if (status.currentPage < model.pages[status.currentModule].length - 1)
				{
					status.currentPage++;
				}
				else if (status.currentModule < model.pages.length - 1)
				{
					if (status.currentModule == status.maxModule)
						status.maxPage = 0;

					status.currentPage = 0;
					status.currentModule++;
				}

				_navDirection = 1;

				loadPage();
			}
		}

		public function backPage():void
		{
			if (_onBeforeBackPage != null)
			{
				Logger.log("NavController.backPage >> _onBeforeBackPage");
				_onBeforeBackPage();
			}
			else
			{
				if (status.currentPage > 0)
				{
					status.currentPage--;
				}
				else if (status.currentModule > 0)
				{
					status.currentModule--;
					status.currentPage = model.pages[status.currentModule].length - 1;
				}

				_navDirection = -1;

				loadPage();
			}
		}

		/**
		 * Sempre que for ter algum evento de navegacao, chamar esse metodo, que
		 * alem de navegar para a pagina desejada, também atualiza o index para
		 * correção da navegacao linear.
		 * @param    pg - nome da pagina para onde irá se navegar.
		 */
		public function navigateTo(pg:String):void
		{
			var page:PageData = getPageByName(pg);
			navigateToPageIndex(page.index);
		}

		/**
		 * Navega para uma página em especifico, determinada por modulo e pagina.
		 * @param    module - numero do modulo a ser navegado.
		 * @param    page - numero da pagina a ser navegada.
		 */
		public function navigateToIndex(module:int, page:int):void
		{
			_navDirection = -1;

			if (module > status.currentModule)
			{
				_navDirection = 1;
			}
			else if (module == status.currentModule && status.currentPage < page)
			{
				_navDirection = 1;
			}

			status.currentPage = page;
			status.currentModule = module;

			loadPage();
		}

		/**
		 * Navega para uma página em especifico, determinada pelo indice da pagina.
		 * @param    index  numero da pagina a ser navegada.
		 */
		public function navigateToPageIndex(index:int):void
		{
			if (model.pageQueue[index])
				var page:PageData = model.pageQueue[index] as PageData;
			else
				return;

			_navDirection = -1;

			if (page.moduleIndex > status.currentModule)
			{
				_navDirection = 1;
			}
			else if (page.moduleIndex == status.currentModule && status.currentPage < page.localIndex)
			{
				_navDirection = 1;
			}

			status.currentPage = page.localIndex;
			status.currentModule = page.moduleIndex;

			loadPage();
		}

		/**
		 * Returns last page user has viewed
		 */
		public function getUserLastPage():PageData
		{
			var lastMod:int = status.maxModule;
			var lastPage:int = status.maxPage;
			var userLastPage:PageData = PageData(model.pages[lastMod][lastPage]);

			return userLastPage;
		}

		/**
		 * Metodo que deve ser chamado para carregar a pagina que esta indicado
		 * pelo status.currentPage.
		 */
		public function loadPage():void
		{
			if (ebook.getEbookController().isConsultMode == false)
			{
				if (status.currentModule > status.maxModule)
				{
					status.maxModule = status.currentModule;

					if (status.currentPage != status.maxPage)
						status.maxPage = (status.currentPage >= model.pages[status.maxModule].length) ? model.pages[status.maxModule].length - 1 : status.currentPage;
				}

				if (status.currentModule == status.maxModule && status.currentPage > status.maxPage)
					status.maxPage = status.currentPage;
			}

			_onBeforeNextPage = null;
			_onBeforeBackPage = null;

			onChange.dispatch(getCurrentPage());
		}

		/**
		 * Retorna a direcao da navegação, 1 se for para a animacao ser da direita para a esqueda
		 * e -1 se for para a animacao ser da esqeurda para a direita.
		 */
		public function get navDirection():int
		{
			return _navDirection;
		}

		/**
		 * Seta a direcao da animacao da navegacao, 1 para avancar, e -1 para voltar.
		 */
		public function set navDirection(value:int):void
		{
			_navDirection = value;
		}

		public function get onBeforeNextPage():Function
		{
			return _onBeforeNextPage;
		}

		public function set onBeforeNextPage(value:Function):void
		{
			_onBeforeNextPage = value;
		}

		public function get onBeforeBackPage():Function
		{
			return _onBeforeBackPage;
		}

		public function set onBeforeBackPage(value:Function):void
		{
			_onBeforeBackPage = value;
		}

		public function get totalModules():uint
		{
			return _totalModules;
		}

		public function set totalModules(value:uint):void
		{
			_totalModules = value;
		}

		public function get totalPages():uint
		{
			return _totalPages;
		}

		public function set totalPages(value:uint):void
		{
			_totalPages = value;
		}

		public function get xmlData():XML
		{
			return _xmlData;
		}

		public function set xmlData(value:XML):void
		{
			_xmlData = value;
		}

		public function get onChange():Signal
		{
			return _onChange;
		}

		public function set onChange(value:Signal):void
		{
			_onChange = value;
		}

		public function get modPagesCount():Array
		{
			return _modPagesCount;
		}

		public function set modPagesCount(value:Array):void
		{
			_modPagesCount = value;
		}

		public function getCurrentPage():PageData
		{
			var page:PageData = model.pages[status.currentModule][status.currentPage];
			return page;
		}

		public function getPages():Vector.<PageData>
		{
			return model.pageQueue;
		}

		public function getPageByIndex(index:int):PageData
		{
			var page:PageData = model.pageQueue[index];
			return page;
		}

		public function getPageByName(name:String):PageData
		{
			for (var i:int = 0; i < model.pageQueue.length; i++)
			{
				var page:PageData = model.pageQueue[i] as PageData;
				if (page.branch == name)
					return page;
			}

			return null;
		}

	}

}