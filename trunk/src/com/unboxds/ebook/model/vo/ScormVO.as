/**
 * Created by Naizer on 02/10/2015.
 */
package com.unboxds.ebook.model.vo
{
	public class ScormVO
	{
		private var _lessonMode:String;
		private var _lessonStatus:String;
		private var _scoreMax:int;
		private var _scoreMin:int;
		private var _scoreRaw:int;
		private var _sessionTime:String;
		private var _totalTime:String;
		private var _studentId:String;
		private var _studentName:String;
		private var _suspendData:String;

		public function ScormVO()
		{
		}

		public function get lessonMode():String
		{
			return _lessonMode;
		}

		public function set lessonMode(value:String):void
		{
			_lessonMode = value;
		}

		public function get lessonStatus():String
		{
			return _lessonStatus;
		}

		public function set lessonStatus(value:String):void
		{
			_lessonStatus = value;
		}

		public function get scoreMax():int
		{
			return _scoreMax;
		}

		public function set scoreMax(value:int):void
		{
			_scoreMax = value;
		}

		public function get scoreMin():int
		{
			return _scoreMin;
		}

		public function set scoreMin(value:int):void
		{
			_scoreMin = value;
		}

		public function get scoreRaw():int
		{
			return _scoreRaw;
		}

		public function set scoreRaw(value:int):void
		{
			_scoreRaw = value;
		}

		public function get sessionTime():String
		{
			return _sessionTime;
		}

		public function set sessionTime(value:String):void
		{
			_sessionTime = value;
		}

		public function get totalTime():String
		{
			return _totalTime;
		}

		public function set totalTime(value:String):void
		{
			_totalTime = value;
		}

		public function get studentId():String
		{
			return _studentId;
		}

		public function set studentId(value:String):void
		{
			_studentId = value;
		}

		public function get studentName():String
		{
			return _studentName;
		}

		public function set studentName(value:String):void
		{
			_studentName = value;
		}

		public function get suspendData():String
		{
			return _suspendData;
		}

		public function set suspendData(value:String):void
		{
			_suspendData = value;
		}
	}
}
