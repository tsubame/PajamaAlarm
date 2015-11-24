//
//  WheatherGetter.swift
//
//  お天気データを取得するライブラリ
//  要： SwiftyJSON
//
//  使い方：
//      var _weatherGetter = WheatherGetter()
//		_weatherGetter.exec( { wData, dDatas in
//			let todaysWeatherName  = dDatas[0].weather
//		})
//
//
//  参考：お天気コード
//  http://openweathermap.org/weather-conditions
//

import Foundation

// お天気データ保存用の構造体
struct WeatherData {

	var weatherDate: NSDate = NSDate() // お天気の日時
	var updateDate : NSDate	= NSDate() // 更新日時
	var weather    : String	= ""	   // 天気（日本語）
	var weatherEng : String	= ""	   // 天気（英語）
	var weatherCode: String	= ""	   // 天気コード
	var weatherImg : String	= ""	   // 天気画像
	var maxTemp	   : Double = 0 	   // 最高気温
	var minTemp    : Double = 0 	   // 最低気温
	var temp	   : Double = 0 	   // 気温
	
	// 辞書型に変換
	func toDictionary() -> [String: NSObject] {
		return [
			"weatherDate" : nsDateToJPDateStr(weatherDate),
			"updateDate"  : nsDateToJPDateStr(updateDate),
			"weather"     : weather,
			"weatherEng"  : weatherEng,
			"weatherCode" : weatherCode,
			"weatherImg"  : weatherImg,
			"maxTemp"	  : maxTemp,
			"minTemp"     : minTemp,
			"temp"		  : temp
		]
	}
		
	// 日本の日時に変換
	func nsDateToJPDateStr(date: NSDate) -> String {
		let fmt        = NSDateFormatter()
		fmt.locale     = NSLocale(localeIdentifier: "ja")
		fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		return fmt.stringFromDate(date)
	}
}


class WeatherGetter {
	
	// OpenWeatherMap API
	let OPEN_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/" //
	let CURRENT_API_STR      = "weather"								 //
	let THREE_HOUR_API_STR   = "forecast"								 //
	let DAILY_API_STR        = "forecast/daily"							 //
	let API_PARAM            = "?units=metric&"							 //
	let OPENWEATHER_API_KEY  = "appid=69f598f452dd4e049991200bc39b7aac&" //
	
	// 自作PHP API
	let WEATHER_PHP_API_URL = "http://taltal.catfood.jp/php/getWeather.php?" // 天気取得用API
	
	// OpenWeatherMap API お天気コード
	let WEATHER_CODE = [ "01": "晴れ", "02": "晴れ",
						 "03": "曇り", "04": "曇り",
						 "09": "豪雨", "10": "雨",  "11": "雷雨",
						 "13": "雪",   "50": "霧" ]
	
	// プライベート変数
	var _latitude : String?				  // 緯度
	var _longiTude: String?				  // 経度
	var _weatherDatas   = [WeatherData]() // お天気データ保存用
	var _currentWeather = WeatherData()   // 同上
	

	// 天気を取得　　使い方： exec() { wDatas in  終了後の処理 }
	func exec(onComplete: (dDatas: [WeatherData]) -> () ) {
		_weatherDatas = [WeatherData]()
		
		self.getDailyWeather() { _ in
			onComplete(dDatas: self._weatherDatas)
		}
	}
	
	//======================================================
	// 天気の取得
	//======================================================
	
	// 日別の天気を取得 　使い方： getDailyWeather() { wds in  処理内容 }
	func getDailyWeather(onComplete: (weatherDatas: [WeatherData]) -> ()) {
		if getLocationFromPref() == false {
			onComplete(weatherDatas: self._weatherDatas)
			return
		}
		
		let url = OPEN_WEATHER_API_URL + DAILY_API_STR + API_PARAM + OPENWEATHER_API_KEY + "lat=\(_latitude!)&lon=\(_longiTude!)"
		httpRequestAsync(url) {
			onComplete(weatherDatas: self._weatherDatas)
		}
	}
	
	// 現在の天気を取得。PHP経由。　　使い方： getCurrentWeather() { 終了後の処理 }
	func getCurrentWeather(onComplete: () -> ()) {
		if getLocationFromPref() == false {
			onComplete()
			return
		}
		
		let url = WEATHER_PHP_API_URL + "lat=\(_latitude!)&lon=\(_longiTude!)"
		httpRequestAsync(url) {
			onComplete()
		}
	}
	
	// 3時間毎の天気を取得 　使い方： getDailyWeather() { wds in  処理内容 }
	func get3HourWeather(onComplete: (weatherDatas: [WeatherData]) -> ()) {
		if getLocationFromPref() == false {
			onComplete(weatherDatas: self._weatherDatas)
			return
		}
		
		let url = OPEN_WEATHER_API_URL + THREE_HOUR_API_STR + API_PARAM + OPENWEATHER_API_KEY + "lat=\(_latitude!)&lon=\(_longiTude!)"
		httpRequestAsync(url) {
			onComplete(weatherDatas: self._weatherDatas)
		}
	}
	
	//======================================================
	// 緯度、経度
	//======================================================
	
	// 緯度、経度をプリファレンスから取得
	func getLocationFromPref() -> Bool {
		let pref   = NSUserDefaults.standardUserDefaults()
		_latitude  = pref.stringForKey("latitude")
		_longiTude = pref.stringForKey("longitude")
		
		if _latitude == nil || _longiTude == nil {
			print("位置情報のデータがないため、お天気情報の取得が出来ません。")
			return false
		}
		
		return true
	}
	
	//======================================================
	// HTTP通信関連
	//======================================================
	
	// HTTP通信を非同期で行う
	func httpRequestAsync(url: String, onComplete: () -> ()) {
		print("お天気データの取得中...\(url)")
		
		let nsUrl = NSURL(string: url)
		let req   = NSURLRequest(URL: nsUrl!)

		let task = NSURLSession.sharedSession().dataTaskWithRequest(req) { data, response, error in
			self.jsonToWeatherData(response, data: data, error: error)
			onComplete()
		}
		task.resume()
	}
	
	//======================================================
	// Jsonデータの変換
	//======================================================
	
	// 通信終了後に呼び出す
	func jsonToWeatherData(res: NSURLResponse!, data: NSData!, error: NSError!) {
		if error != nil {
			print(error.description)
			return
		}
			
		let json = JSON(data: data!)
		
		if json["list"].isEmpty {
			jsonToCurrentWeatherData(json)
		} else {
			jsonToWeatherDatas(json)
		}
	}
	
    func jsonToWeatherDatas(json: JSON) {
		let weatherID: String? = json["list"][0]["weather"][0]["id"].stringValue
		if weatherID == nil {
			print("お天気を取得できませんでした")
			return
		}
		
		//_dailyWeatherDatas = [WeatherData]()
		_weatherDatas = [WeatherData]()
		
		for (i, _) in json["list"].enumerate() {
			var wd = json["list"][i]
			var wData = WeatherData()
			wData.weatherDate = NSDate(timeIntervalSince1970: wd["dt"].doubleValue)
			wData.weatherEng  = wd["weather"][0]["description"].stringValue
			wData.weatherImg  = wd["weather"][0]["icon"].stringValue
			wData.weatherCode = wd["weather"][0]["id"].stringValue
			wData.maxTemp     = wd["temp"]["max"].doubleValue
			wData.minTemp     = wd["temp"]["min"].doubleValue
			wData.temp        = wd["main"]["temp"].doubleValue
			wData.weather     = getJWeatherFromWImg(wd["weather"][0]["icon"].stringValue)
			
			//_dailyWeatherDatas.append(wData)
			_weatherDatas.append(wData)
		}
    }
	
	func jsonToCurrentWeatherData(json: JSON) {
		_currentWeather = WeatherData()
		
		let wCode: String? = json["weather"][0]["id"].stringValue
		if wCode == nil {
			print("お天気を取得できませんでした")
			return
		}
		
		_currentWeather.weatherEng  = json["weather"][0]["main"].stringValue
		_currentWeather.weatherCode = json["weather"][0]["id"].stringValue
		_currentWeather.weatherImg  = json["weather"][0]["icon"].stringValue
		_currentWeather.temp		= json["main"]["temp"].doubleValue
		_currentWeather.weather     = getJWeatherFromWImg(json["weather"][0]["icon"].stringValue)
		
		print("お天気を取得しました。")
	}
	
	//======================================================
	// OpenWeather関連
	//======================================================
	
    // 現在の天気を日本語の文字列で返す
	func getJWeatherFromWImg(wImg: String) -> String {
		if wImg.isEmpty {
			print("天気コードが空です")
			return ""
		}
		
		let prefix: String = (wImg as NSString).substringToIndex(2)
		var w: String = "よく分かりません"
		
		for (code, wName) in WEATHER_CODE {
			if code == prefix {
				w = wName
			}
		}
		
		return w
	}

	/*
	var _currentWeather    = WeatherData()
	var _dailyWeatherDatas = [WeatherData]()
	var _3HourWeatherDatas = [WeatherData]()
		//var _errorMessage: String?	// エラーメッセージ
*/
	
	/*
	let CURRENT_WEATHER_API_URL    = "http://api.openweathermap.org/data/2.5/weather?units=metric&"					 // 現在の天気 lat=32.82&lon=129.991229726123"
	let DAILY_WEATHER_API_URL      = "http://api.openweathermap.org/data/2.5/forecast/daily?mode=json&units=metric&" // 今日、明日の天気 lat=32.82&lon=129.991229726123"
	let THREE_HOUR_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/forecast?mode=json&units=metric&"		 // 3時間毎の天気
	*/

}
