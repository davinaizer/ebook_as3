package com.unboxds.ebook.services
{
	import com.unboxds.ebook.model.vo.EbookDTO;

	import org.osflash.signals.ISignal;

	/**
	 * ...
	 * @author UNBOX® - http://www.unbox.com.br - All rights reserved.
	 */
	public interface IEbookDataService
	{
		function load():void;

		function save(data:EbookDTO):void;
		
		function get isAvailable():Boolean;

		function get onLoad():ISignal;

		function get onSave():ISignal;

		function get onLoadError():ISignal;

		function get onSaveError():ISignal;
	}

}