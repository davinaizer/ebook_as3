package com.unboxds.ebook.controller
{
	import com.adobe.utils.ArrayUtil;
	import com.gaiaframework.api.Gaia;
	import com.gaiaframework.events.GaiaEvent;
	import com.greensock.TweenMax;
	import com.unboxds.button.ToggleButton;
	import com.unboxds.ebook.EbookApi;
	import com.unboxds.ebook.events.NavEvent;
	import com.unboxds.ebook.events.SearchEvent;
	import com.unboxds.ebook.model.vo.PageVO;
	import com.unboxds.ebook.view.NavBarView;
	import com.unboxds.ebook.view.components.AbsProgressMeter;
	import com.unboxds.ebook.view.components.BarMeter;
	import com.unboxds.ebook.view.components.InteractiveBarMeter;
	import com.unboxds.ebook.view.ui.ContentObject;
	import com.unboxds.ebook.view.ui.Dashboard;
	import com.unboxds.ebook.view.ui.HelpPanel;
	import com.unboxds.ebook.view.ui.SearchPanel;
	import com.unboxds.ebook.view.ui.UIPanel;
	import com.unboxds.utils.ArrayUtils;
	import com.unboxds.utils.KeyObject;
	import com.unboxds.utils.Logger;
	import com.unboxds.utils.TweenParser;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;

	/**
	 * ...
	 * @author UNBOX® - http://www.unbox.com.br - All rights reserved. © 2009-2015
	 */
	public class UIController extends ContentObject
	{
		private var navBar:NavBarView;
		private var dashboard:Dashboard;
		private var progressMeter:AbsProgressMeter;
		private var helpPanel:HelpPanel;

		private var searchPanel:SearchPanel;
		private var currentPanel:UIPanel;

		private var currentBtn:ToggleButton;
		private var currentPage:PageVO;

		private var isNavigationAvailable:Boolean;
		private var keyObj:KeyObject;
		private var contentTween:TweenMax;

		// for import only
		BarMeter;
		InteractiveBarMeter;

		public function UIController(contentXML:XML = null, stylesheet:StyleSheet = null)
		{
			super(contentXML, stylesheet);

			Logger.log("UIController.UIController > contentXML: " + (contentXML != null) + ", stylesheet: " + (stylesheet != null));

			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			init();
		}

		public function init():void
		{
			Logger.log("UIController.init");

			isNavigationAvailable = false;

			setupStage();
			initEvents();
			parseContent();

			Gaia.api.beforeGoto(onBeforeGoto, false, true);
		}

		private function setupStage():void
		{
			//-- DASHBOARD
			var dashboardData:XML = XML(XMLList(contentXML.component.(@type == "Dashboard")).toXMLString());
			dashboard = new Dashboard(dashboardData, stylesheet);

			//-- NAVBAR
			var navBarData:XML = XML(XMLList(contentXML.component.(@type == "NavBar")).toXMLString());
			navBar = new NavBarView(navBarData, stylesheet);

			//-- PROGRESS METER
			var pmData:XML = XML(XMLList(contentXML.component.(@type == "ProgressMeter")).toXMLString());
			var PmClass:Class = getDefinitionByName(pmData.@className) as Class;
			progressMeter = new PmClass(pmData, stylesheet) as AbsProgressMeter;
			progressMeter.setMax(EbookApi.getNavModel().totalPages);

			//-- HELP PANEL
			var helpPanelData:XML = XML(XMLList(contentXML.component.(@type == "HelpPanel")).toXMLString());
			helpPanel = new HelpPanel(helpPanelData, stylesheet);

			//-- SEARCH PANEL
			var searchPanelData:XML = XML(XMLList(contentXML.component.(@type == "SearchPanel")).toXMLString());
			searchPanel = new SearchPanel(searchPanelData, stylesheet);

			addChild(dashboard);
			addChild(navBar);
			addChild(progressMeter);
			addChild(helpPanel);
			addChild(searchPanel);

			// -- check for depth management
			if ("@depth" in searchPanel.contentXML)
				setChildIndex(searchPanel, parseInt(searchPanel.contentXML.@depth));
			if ("@depth" in helpPanel.contentXML)
				setChildIndex(helpPanel, parseInt(helpPanel.contentXML.@depth));
			if ("@depth" in dashboard.contentXML)
				setChildIndex(dashboard, parseInt(dashboard.contentXML.@depth));
			if ("@depth" in navBar.contentXML)
				setChildIndex(navBar, parseInt(navBar.contentXML.@depth));
			if ("@depth" in progressMeter.contentXML)
				setChildIndex(progressMeter as DisplayObject, parseInt(progressMeter.contentXML.@depth));
		}

		private function initEvents():void
		{
			navBar.addEventListener(MouseEvent.CLICK, navbarHandler);
			navBar.addEventListener(SearchEvent.SEARCH, searchHandler);
			navBar.addEventListener(SearchEvent.SEARCH_END, searchHandler);
			navBar.addEventListener(SearchEvent.SEARCH_COMPLETE, searchHandler);

			dashboard.addEventListener(MouseEvent.CLICK, dashboardClickHandler);
			dashboard.addEventListener(NavEvent.GOTO_PAGE, onGotoPage);

			searchPanel.addEventListener(SearchEvent.INDEX_COMPLETE, searchHandler);
			searchPanel.addEventListener(SearchEvent.SEARCH_COMPLETE, searchHandler);
			searchPanel.addEventListener(MouseEvent.CLICK, searchHandler);

			//check for clicks outside UI
			stage.addEventListener(MouseEvent.CLICK, stageHandler);

			if (EbookApi.getEbookModel().enableDebugPanel == true)
			{
				keyObj = new KeyObject(this.stage);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}

			if (navBar.isKeyboardAvailable)
				stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}

		private function stageHandler(e:MouseEvent):void
		{
			if (e.type == MouseEvent.CLICK)
			{
				if (currentPanel && !this.contains(e.target as DisplayObject))
					closePanels();
			}
		}

		// ************  HANDLERS *****************
		private function keyDownHandler(e:KeyboardEvent):void
		{
			// check keys combination to Debug Panel
			if (keyObj.isDown(Keyboard.CONTROL) && keyObj.isDown(Keyboard.SHIFT) && keyObj.isDown(Keyboard.NUMBER_1))
			{
				if (EbookApi.getDebugPanel().view.visible)
					EbookApi.getDebugPanel().hide();
				else
					EbookApi.getDebugPanel().show();
			}

			if (keyObj.isDown(Keyboard.ESCAPE))
				closePanels();
		}

		private function keyUpHandler(e:KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case Keyboard.RIGHT:
				case Keyboard.SPACE:
					if (navBar.getNextButtonStatus())
						EbookApi.getNavController().nextPage();
					break;

				case Keyboard.LEFT:
					if (navBar.getBackButtonStatus())
						EbookApi.getNavController().backPage();
					break;
			}
		}

		private function dashboardClickHandler(e:MouseEvent):void
		{
			if (e.target is DisplayObjectContainer)
			{
				var srcName:String = e.target.name;
				var prefix:String = srcName.split("_")[0];
				var index:int = parseInt(srcName.split("_")[1]);

				switch (prefix)
				{
					case "btBookmarkItem":
					case "btSearchResult":
						gotoPage(index);
						break;
				}
			}
		}

		private function navbarHandler(e:MouseEvent):void
		{
			var sourceName:String = e.target.name;
			switch (sourceName)
			{
				case "nextBtn":
					EbookApi.getNavController().nextPage();
					break;

				case "backBtn":
					EbookApi.getNavController().backPage();
					break;

				case "bookmarkRemoveBtn":
				case "bookmarkAddBtn":
					bookmarkPage();
					break;

				case "dashboardBtn":
					togglePanel(dashboard as UIPanel, e.target as ToggleButton);
					break;

				case "helpBtn":
					togglePanel(helpPanel as UIPanel, e.target as ToggleButton);
					break;

				default:
					break;
			}

			e.stopPropagation();
		}

		private function searchHandler(e:Event):void
		{
			switch (e.type)
			{
				case SearchEvent.INDEX_COMPLETE:
					navBar.searchBox.enable(true);
					break;

				case SearchEvent.SEARCH:
					searchPanel.search(SearchEvent(e).data);
					break;

				case SearchEvent.SEARCH_END:
					closePanels();
					break;

				case SearchEvent.SEARCH_COMPLETE:
					togglePanel(searchPanel as UIPanel, null);
					break;

				case MouseEvent.CLICK:
					var srcName:String = e.target.name;
					var prefix:String = srcName.split("_")[0];
					var index:int = parseInt(srcName.split("_")[1]);
					if (prefix == "btSearchResult")
						gotoPage(index);
					break;

				default:
			}
		}

		private function togglePanel(panel:UIPanel, toggleBtn:ToggleButton):void
		{
			if (currentPanel == null)
			{
				panel.open();
				if (toggleBtn)
					toggleBtn.toggle();

				currentPanel = panel;
				currentBtn = toggleBtn;

				contentTween.play();
			}
			else
			{
				if (panel != currentPanel)
				{
					//close last opened panel
					currentPanel.close();
					if (currentBtn && currentBtn.isToggled)
						currentBtn.toggle();

					// open the new panel	
					panel.open();
					if (toggleBtn)
						toggleBtn.toggle();

					currentPanel = panel;
					currentBtn = toggleBtn;

					contentTween.play();
				}
				else
				{
					if (panel != searchPanel)
						closePanels();
				}
			}
		}

		private function closePanels():void
		{
			if (currentPanel && currentPanel.isOpen)
				currentPanel.close();

			if (currentBtn && currentBtn.isToggled)
				currentBtn.toggle();

			if (navBar.searchBox.isOpen)
				navBar.searchBox.close();

			currentPanel = null;
			currentBtn = null;

			if (contentTween)
				contentTween.reverse();
		}

		private function bookmarkPage():void
		{
			// -- SORT ARRAY
			var pageFound:int = ArrayUtils.binarySearch(EbookApi.getEbookModel().bookmarks, currentPage.index);
			if (pageFound > -1)
			{
				dashboard.removeBookmark(currentPage);
				navBar.bookmarkPage(false);

				ArrayUtil.removeValueFromArray(EbookApi.getEbookModel().bookmarks, currentPage.index);
			}
			else
			{
				dashboard.addBookmark(currentPage);
				navBar.bookmarkPage(true);

				EbookApi.getEbookModel().bookmarks.push(currentPage.index);
				EbookApi.getEbookModel().bookmarks.sort(Array.NUMERIC);
			}
		}

		private function checkBookmark():void
		{
			var pageUID:int = currentPage.index;
			var pageFound:int = ArrayUtils.binarySearch(EbookApi.getEbookModel().bookmarks, pageUID);
			if (pageFound > -1)
				navBar.bookmarkPage(true);
			else
				navBar.bookmarkPage(false);
		}

		private function onGotoPage(e:NavEvent):void
		{
			var index:int = EbookApi.getNavModel().getPageByName(e.pageID).index;
			gotoPage(index);
		}

		private function gotoPage(index:uint):void
		{
			if (currentPage.index != index)
			{
				EbookApi.getNavController().navigateToPageIndex(index);
			}
			else
			{
				closePanels();
			}
		}

		private function onBeforeGoto(e:GaiaEvent):void
		{
			currentPage = EbookApi.getNavModel().getCurrentPage();

			closePanels();

			progressMeter.enable(false);

			navBar.enableNextButton(false);
			navBar.block("11111");

			Gaia.api.beforeTransitionIn(onBeforeTransitionIn, false, true);
			Gaia.api.afterTransitionIn(onAfterTransitionIn, false, true);
		}

		private function onBeforeTransitionIn(e:GaiaEvent):void
		{
			checkBookmark();

			contentTween = TweenParser.getTweenFromXML(Gaia.api.getPage(Gaia.api.getCurrentBranch()).content, contentXML.tween.tween.(@id == "contentTween")[0]);

			progressMeter.setProgress(currentPage.index + 1);
			progressMeter.setSecondaryProgress(EbookApi.getNavModel().getUserLastPage().index + 1);
		}

		private function onAfterTransitionIn(e:GaiaEvent):void
		{
			navBar.block("00000");

			progressMeter.enable(true);
			currentPage.showProgress ? progressMeter.show() : progressMeter.hide();

			if (currentPage.navbarStatus != null)
			{
				navBar.status(currentPage.navbarStatus);
			}
			else
			{
				navBar.status("11111");

				var lastUserPage:PageVO = EbookApi.getNavModel().getUserLastPage();
				if (EbookApi.getEbookModel().isConsultMode || lastUserPage.index > currentPage.index)
					navBar.enableNextButton(true);
			}

			stage.focus = stage;
			isNavigationAvailable = true;

			Gaia.api.beforeGoto(onBeforeGoto, false, true);
		}

		// -- PUBLIC EXTERNAL FUNCTIONS
		// TODO REFACTOR THESE FUNTCIONS. MAYBE SHOULD BE PLACED SOMEWHERE
		public function enableNextButton(value:Boolean = true):void
		{
			navBar.enableNextButton(value);
		}

		public function setNavStatus(value:String):void
		{
			navBar.status(value);
		}
	}
}