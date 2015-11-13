//
//  WheatherGetter.swift
//
//  お天気データを取得するライブラリ
//  要： SwiftyJSON
//
//
// 参考：お天気コード
// http://openweathermap.org/weather-conditions
//

import Foundation

struct CurrentWeatherData {
	// 更新日時
	var updateDate: NSDate
	// 天気
	var weatherNameJp: String
	// 天気（英語）
	var weatherNameEng: String
	// 天気コード
	var weatherCode: String
	// 天気画像
	var weatherImg: String
	// 気温
	var temp: Double
	
	init() {
		updateDate = NSDate()
		weatherCode = ""
		weatherImg = ""
		weatherNameJp = ""
		weatherNameEng = ""
		temp = 0
	}
}

struct ThreeHourWeatherData {
	// 更新日時
	var updateDate: NSDate
	//
	var timeFrom: NSDate
	
	var timeTo: NSDate
	
	// 天気
	var weatherNameJp: String
	// 天気（英語）
	var weatherNameEng: String
	// 天気コード
	var weatherCode: String
	// 天気画像
	var weatherImg: String
	// 最高気温
	var maxTemp: Double
	// 最低気温
	var minTemp: Double
	
	init() {
		updateDate = NSDate()
		timeTo = NSDate()
		timeFrom = NSDate()
		weatherCode = ""
		weatherImg = ""
		weatherNameJp = ""
		weatherNameEng = ""
		maxTemp = 0
		minTemp = 0
	}
}

struct DailyWeatherData {
	// 更新日時
	var updateDate: NSDate
	// 天気
	var weatherNameJp: String
	// 天気（英語）
	var weatherNameEng: String
	// 天気コード
	var weatherCode: String
	// 天気画像
	var weatherImg: String
	// 最高気温
	var maxTemp: Double
	// 最低気温
	var minTemp: Double
	
	init() {
		updateDate = NSDate()
		weatherCode = ""
		weatherImg = ""
		weatherNameJp = ""
		weatherNameEng = ""
		maxTemp = 0
		minTemp = 0
	}
}

class WeatherGetter: NSObject {
	
	// OpenWeatherMap API 現在の天気
	let CURRENT_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather?units=metric&" //lat=32.82&lon=129.991229726123"
	// OpenWeatherMap API 今日、明日の天気
	let DAILY_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?mode=json&units=metric&" //lat=32.82&lon=129.991229726123"
	// OpenWeatherMap API 3時間ごとの天気
	let THREE_HOUR_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/forecast?mode=json&units=metric&"
	
	// 緯度、経度取得用API
	let GEO_API_URL = "http://taltal.catfood.jp/php/getCity.php"
	
	// エラー
	var _error: Bool = false
	
	var _errorMessage: String?

	
	var _currentWeather = CurrentWeatherData()

	var _todaysWeather = DailyWeatherData()
	
	var _tomorrowsWeather = DailyWeatherData()
	
	
	override init() {
		super.init()
	}
	
	// 天気の更新　位置情報を受け取る
	func updateWeather() {
		
		//var lGetter = LocationGetter()
		//lGetter.startUpdateLocation()
		
		//let pref = NSUserDefaults.standardUserDefaults()
		//var latitude: String?  = pref.stringForKey("latitude")
		//var longitude: String? = pref.stringForKey("longitude")
		
		/*
		if latitude != nil {
			_latitude  = latitude!
			_longitude = longitude!
			
			//getCurrentWeather()
			//getDailyWeather()
		}*/
	}
	
	// 都市の緯度、経度を取得
	func getCityGeo(onComplete: (lat: String?, long: String?, eMessage: String?) -> ()) {
		let nsUrl = NSURL(string: GEO_API_URL)
		let req   = NSURLRequest(URL: nsUrl!)
		
		print("都市の緯度、経度を取得中...\(GEO_API_URL)")
		
		NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {
			res, data, error in
			
			var lat: String?  = nil
			var long: String? = nil
			
			if error == nil {
				self._errorMessage = nil
				let json = JSON(data: data!)
				lat  = json["cityLatitude"].stringValue
				long = json["cityLongitude"].stringValue
			} else {
				self._errorMessage = error!.description
				print("通信エラー\(self._errorMessage)")
			}
			
			onComplete(lat: lat, long: long, eMessage: self._errorMessage)
		}
	}
	
	// 現在の天気を取得　　使い方： getCurrentWeather(lat, long: long) { w, error in  終了後の処理 }
	func getCurrentWeather(lat: String, long: String, onComplete: (wData: CurrentWeatherData, eMessage: String?) -> ()) {
		let url = CURRENT_WEATHER_API_URL + "lat=\(lat)&lon=\(long)"
		print("現在のお天気取得中...\(url)")
		
		accessOpenWeatherAPI(url) {
			onComplete(wData: self._currentWeather, eMessage: self._errorMessage)
		}
	}
	
	// 今日、明日の天気を取得 　使い方： getDailyWeather(lat, long: long) { td, tm, error in  処理内容 }
	func getDailyWeather(lat: String, long: String, onComplete: (tdWeather: DailyWeatherData, tmWeather: DailyWeatherData, eMessage: String?) -> ()) {
		let url = DAILY_WEATHER_API_URL + "lat=\(lat)&lon=\(long)"
		print("今日、明日のお天気取得中...\(url)")
		
		accessOpenWeatherAPI(url) {
			onComplete(tdWeather: self._todaysWeather, tmWeather: self._tomorrowsWeather, eMessage: self._errorMessage)
		}
	}
	
	// HTTP通信を非同期で行う
	func accessOpenWeatherAPI(url: String, onComplete: () -> ()) {
		let nsUrl = NSURL(string: url)
		let req   = NSURLRequest(URL: nsUrl!)
//
		NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {
			res, data, error in
			
			self.fetchResponse(res, data: data, error: error)
			onComplete()
		}
	}
	
	// 通信終了後に呼び出す
	func fetchResponse(res: NSURLResponse!, data: NSData!, error: NSError!) {
		if error == nil {
			_error    = false
			_errorMessage = nil
			
			let json = JSON(data: data!)
			if !json["list"] {
				getWeatherDataCurrent(json)
			} else {
				getWeatherDataDaily(json)
			}
		} else {
			_error = true
			_errorMessage = error.description
			
			print("通信エラー\(_errorMessage)")
		}
	}
	
    func getWeatherDataCurrent(json: JSON) {
		
		_currentWeather = CurrentWeatherData()
		
		let weatherID: String? = json["weather"][0]["id"].stringValue
		
		if weatherID == nil {
			print("お天気を取得できませんでした")
			return
		}
		
		_currentWeather.weatherCode    = json["weather"][0]["id"].stringValue
		_currentWeather.weatherCode    = json["weather"][0]["icon"].stringValue
		_currentWeather.weatherNameJp  = getJWeatherFromWImg(json["weather"][0]["icon"].stringValue)
		_currentWeather.weatherNameEng = json["weather"][0]["main"].stringValue
		_currentWeather.temp           = json["main"]["temp"].doubleValue
		
        print("お天気を取得しました。")
    }
    
    func getWeatherDataDaily(json: JSON) {
        var td = json["list"][0]

		let weatherID: String? = td["weather"][0]["id"].stringValue
		
		if weatherID == nil {
			print("お天気を取得できませんでした")
			return
		}
		
		_todaysWeather = DailyWeatherData()
		_todaysWeather.weatherNameJp  = getJWeatherFromWImg(td["weather"][0]["icon"].stringValue)
		_todaysWeather.weatherNameEng = td["weather"][0]["description"].stringValue
		_todaysWeather.weatherImg     = td["weather"][0]["icon"].stringValue
		_todaysWeather.weatherCode    = td["weather"][0]["id"].stringValue
		_todaysWeather.maxTemp        = td["temp"]["max"].doubleValue
		_todaysWeather.minTemp        = td["temp"]["min"].doubleValue
		
        var tm = json["list"][1]
		
		_tomorrowsWeather = DailyWeatherData()
		_tomorrowsWeather.weatherNameJp  = getJWeatherFromWImg(tm["weather"][0]["icon"].stringValue)
		_tomorrowsWeather.weatherNameEng = tm["weather"][0]["description"].stringValue
		_tomorrowsWeather.weatherImg     = tm["weather"][0]["icon"].stringValue
		_tomorrowsWeather.weatherCode    = tm["weather"][0]["id"].stringValue
		_tomorrowsWeather.maxTemp        = tm["temp"]["max"].doubleValue
		_tomorrowsWeather.minTemp        = tm["temp"]["min"].doubleValue
    }
	
    // 現在の天気を日本語の文字列で返す
    func getJWeatherFromWImg(wImg: String) -> String {
        let prefix: String = (wImg as NSString).substringToIndex(2)
        var w: String = "よく分かりません"
        
        switch(prefix) {
            case "01":
                w = "快晴"
                break
            case "02":
                w = "晴れ"
                break
            case "03":
                w = "曇り"
                break
            case "04":
                w = "曇り"
                break
            case "09":
                w = "豪雨"
                break
            case "10":
                w = "雨"
                break
            case "11":
                w = "雷雨"
                break
            case "13":
                w = "雪"
                break
            case "50":
                w = "霧"
                break
            default:
                break
        }
        
        return w
    }
	
	/*
	func getWeatherNameFromWCode(wCode: Int) -> String {
		let w = ""
		
		let wCodes = [
			800: "快晴", // clear sky
			801: "晴れ", //
			802: "薄曇り", //
			803: "曇り", //
			804: "曇り", //

			500: "小雨", // light rain
			501: "小雨", //
			502: "雨", //
			503: "雨", //
			504: "雨", //
			511: "雪", // freezing rain
			520: "豪雨", //
			521: "豪雨", //
			522: "豪雨", //
			523: "豪雨", //
			524: "豪雨", //
		]
		
		return w
	}*/
}





/** 形式

{
base = "cmc stations";
clouds =     {
all = 20;
};
cod = 200;
coord =     {
lat = "32.83";
lon = "129.99";
};
dt = 1415268000;
id = 1861464;
main =     {
humidity = 63;
pressure = 1017;
temp = "16.36";
"temp_max" = 18;
"temp_min" = 15;
};
name = Isahaya;
sys =     {
country = JP;
id = 7555;
message = "0.0224";
sunrise = 1415223735;
sunset = 1415262305;
type = 1;
};
weather =     (
{
description = "few clouds";
icon = 02n;
id = 801;
main = Clouds;
}
);
wind =     {
deg = 350;
speed = "6.7";
};
})*/
