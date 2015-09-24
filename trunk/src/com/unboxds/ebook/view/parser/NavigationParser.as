/**
 * Created by davinaizer on 9/23/15.
 */
package com.unboxds.ebook.view.parser
{
	import com.unboxds.ebook.Ebook;

	public class NavigationParser extends AbsParser
	{
		private var navActions:Object;

		public function NavigationParser()
		{
		}

		override public function parse():void
		{
			navActions = {};

			var actionCount:int = contentXML.action.length();
			for (var i:int = 0; i < actionCount; i++)
			{
				var type:String = contentXML.action[i].@type;
				var value:String = contentXML.action[i].value;

				navActions[type] = value;

				switch (type)
				{
					case "onBeforeNextPage":
						Ebook.getInstance().getNav().onBeforeNextPage = this.onBeforeNextPage;
						break;

					case "onBeforeBackPage":
						Ebook.getInstance().getNav().onBeforeBackPage = this.onBeforeBackPage;
						break;
				}
			}
		}

		//-- NAVIGATION FUNCTIONS
		private function onBeforeNextPage():void
		{
			Ebook.getInstance().getNav().navigateTo(navActions["onBeforeNextPage"]);
		}

		private function onBeforeBackPage():void
		{
			Ebook.getInstance().getNav().navigateTo(navActions["onBeforeBackPage"]);
		}

	}
}