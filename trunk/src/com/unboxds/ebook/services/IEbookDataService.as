package com.unboxds.ebook.services
{
	import com.unboxds.ebook.model.vo.ScormData;

	import org.osflash.signals.ISignal;

	/**
	 * ...
	 * @author UNBOX® - http://www.unbox.com.br - All rights reserved.
	 */
	public interface IEbookDataService
	{
		function load():void;

		function save(data:ScormData):void;
		
		function get isAvailable():Boolean;

		function get onLoaded():ISignal;

		function get onSaved():ISignal;

		function get onLoadError():ISignal;

		function get onSaveError():ISignal;
	}

}