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



class WeatherGetter: NSObject {
	
	// OpenWeatherMap API
	let CURRENT_WEATHER_API_URL    = "http://api.openweathermap.org/data/2.5/weather?units=metric&"					 // 現在の天気 lat=32.82&lon=129.991229726123"
	let DAILY_WEATHER_API_URL      = "http://api.openweathermap.org/data/2.5/forecast/daily?mode=json&units=metric&" // 今日、明日の天気 lat=32.82&lon=129.991229726123"
	let THREE_HOUR_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/forecast?mode=json&units=metric&"	 // 3時間毎の天気
	let OPENWEATHER_API_KEY        = "appid=69f598f452dd4e049991200bc39b7aac&"
	
	// 自作PHP API
	let WEATHER_PHP_API_URL = "http://taltal.catfood.jp/php/getWeather.php?" // 天気取得用API
	
	// OpenWeatherMap API お天気コード
	let WEATHER_CODE = [
		"01": "晴れ",
		"02": "晴れ",
		"03": "曇り",
		"04": "曇り",
		"09": "豪雨",
		"10": "雨",
		"11": "雷雨",
		"13": "雪",
		"50": "霧"
	]
	
	// プライベート変数
	var _errorMessage: String?	// エラーメッセージ
	var _latitude : String?		// 緯度
	var _longiTude: String?		// 経度
	var _currentWeather    = WeatherData()
	var _dailyWeatherDatas = [WeatherData]()
	var _3HourWeatherDatas = [WeatherData]()
	var _weatherDatas      = [WeatherData]()
	
		
	override init() {
		super.init()
	}
	
	// 緯度、経度をプリファレンスから取得
	func getLocationFromPref() -> Bool {
		let pref   = NSUserDefaults.standardUserDefaults()
		_latitude  = pref.stringForKey("latitude")
		_longiTude = pref.stringForKey("longitude")

		if _latitude == nil || _longiTude == nil {
			_errorMessage = "位置情報のデータがないため、お天気情報の取得が出来ません。"
			return false
		}
		
		return true
	}
	
	// 現在、日別の天気を更新
	func updateWeather(onComplete: (wData: WeatherData, dDatas: [WeatherData]) -> () ) {
		getCurrentWeather() {
			self.getDailyWeather() { _ in
				onComplete(wData: self._currentWeather, dDatas: self._dailyWeatherDatas)
			}
		}
	}
	
	// 現在の天気を取得　　使い方： getCurrentWeather() { wData in  終了後の処理 }
	func getCurrentWeather(onComplete: () -> ()) {
		getLocationFromPref()
		if _latitude == nil || _longiTude == nil {
			_errorMessage = "位置情報のデータがないため、お天気情報の取得が出来ません。"
			return
		}
		
		let url = WEATHER_PHP_API_URL + "lat=\(_latitude!)&lon=\(_longiTude!)"
		print("現在のお天気取得中...\(url)")
		
		httpRequestAsync(url) {
			onComplete()
		}
	}
	
	// 3時間毎の天気を取得 　使い方： getDailyWeather() { wds in  処理内容 }
	func get3HourWeather(onComplete: (weatherDatas: [WeatherData]) -> ()) {
		if getLocationFromPref() == false {
			return
		}
		
		let url = THREE_HOUR_WEATHER_API_URL + OPENWEATHER_API_KEY + "lat=\(_latitude!)&lon=\(_longiTude!)"
		print("3時間毎のお天気取得中...\(url)")
		
		httpRequestAsync(url) {
			onComplete(weatherDatas: self._weatherDatas)
		}
	}
	
	// 日別の天気を取得 　使い方： getDailyWeather() { wds in  処理内容 }
	func getDailyWeather(onComplete: (weatherDatas: [WeatherData]) -> ()) {
		getLocationFromPref()
		if _latitude == nil || _longiTude == nil {
			_errorMessage = "位置情報のデータがないため、お天気情報の取得が出来ません。"
			return
		}

		let url = DAILY_WEATHER_API_URL + OPENWEATHER_API_KEY + "lat=\(_latitude!)&lon=\(_longiTude!)"
		print("今日、明日のお天気取得中...\(url)")
		
		httpRequestAsync(url) {
			onComplete(weatherDatas: self._dailyWeatherDatas)
		}
	}
	
	// HTTP通信を非同期で行う
	func httpRequestAsync(url: String, onComplete: () -> ()) {
		_errorMessage = nil
		
		let nsUrl = NSURL(string: url)
		let req   = NSURLRequest(URL: nsUrl!)

		let task = NSURLSession.sharedSession().dataTaskWithRequest(req) {
			data, response, error in
			
			self.jsonToWeatherData(response, data: data, error: error)
			onComplete()
		}
		task.resume()
	}
	
	// 通信終了後に呼び出す
	func jsonToWeatherData(res: NSURLResponse!, data: NSData!, error: NSError!) {
		if error != nil {
			_errorMessage = error.description
			return
		}
			
		let json = JSON(data: data!)
		
		if json["list"].isEmpty {
			jsonToCurrentWeatherData(json)
		} else {
			jsonToDailyWeatherData(json)
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
	
    func jsonToDailyWeatherData(json: JSON) {
		let weatherID: String? = json["list"][0]["weather"][0]["id"].stringValue
		if weatherID == nil {
			print("お天気を取得できませんでした")
			return
		}
		
		_dailyWeatherDatas = [WeatherData]()
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
			
			_dailyWeatherDatas.append(wData)
			_weatherDatas.append(wData)
		}
    }
	
    // 現在の天気を日本語の文字列で返す
	func getJWeatherFromWImg(wImg: String) -> String {
		if wImg.isEmpty {
			_errorMessage = "天気コードが空です"
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
    func getJWeatherFromWImgOrg(wImg: String) -> String {
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
    }*/
	
	// 現在の天気を取得　　使い方： getCurrentWeather() { wData in  終了後の処理 }
	func getCurrentWeatherOrg(onComplete: (wData: WeatherData) -> ()) {
		let url = CURRENT_WEATHER_API_URL + OPENWEATHER_API_KEY + "lat=\(_latitude!)&lon=\(_longiTude!)"
		print("現在のお天気取得中...\(url)")
		
		httpRequestAsync(url) {
			onComplete(wData: self._currentWeather)
		}
	}
	
	func getDailyWeatherOrg(onComplete: (tdWeather: DailyWeatherData, tmWeather: DailyWeatherData) -> ()) {
		let url = DAILY_WEATHER_API_URL + OPENWEATHER_API_KEY + "lat=\(_latitude!)&lon=\(_longiTude!)"
		print("今日、明日のお天気取得中...\(url)")
		
		httpRequestAsync(url) {
			//onComplete(tdWeather: self._todaysWeather, tmWeather: self._tomorrowsWeather)
		}
	}
	
	/*
	func accessOpenWeatherAPI(url: String, onComplete: () -> ()) {
	let nsUrl = NSURL(string: url)
	let req   = NSURLRequest(URL: nsUrl!)
	//
	let task = NSURLSession.sharedSession().dataTaskWithRequest(req) {
	data, response, error in
	
	self.fetchResponse(response, data: data, error: error)
	onComplete()
	}
	task.resume()
	
	/*
	NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {
	res, data, error in
	
	self.fetchResponse(res, data: data, error: error)
	onComplete()
	}*/
	}*/
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

struct ThreeHourWeatherData {
	// 更新日時
	var updateDate: NSDate
	//
	var timeFrom: NSDate
	
	var timeTo: NSDate
	
	// 天気
	var weather: String
	// 天気（英語）
	var weatherEng: String
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
		weather = ""
		weatherEng = ""
		maxTemp = 0
		minTemp = 0
	}
}

struct CurrentWeatherData {
	var updateDate    : NSDate	// 更新日時
	var weather       : String	// 天気（日本語）
	var weatherEng    : String	// 天気（英語）
	var weatherCode   : String	// 天気コード
	var weatherImg    : String	// 天気画像
	var currentTemp   : Double	// 現在の気温
	var maxTemp		  : Double  // 最高気温
	var minTemp       : Double  // 最低気温
	
	init() {
		updateDate     = NSDate()
		weatherCode    = ""
		weatherImg     = ""
		weather  = ""
		weatherEng = ""
		currentTemp    = 0
		maxTemp		   = 0
		minTemp		   = 0
	}
}

struct DailyWeatherData {
	
	var updateDate    : NSDate	// 更新日時
	var weather : String	// 天気（日本語）
	var weatherEng: String	// 天気（英語）
	var weatherCode   : String	// 天気コード
	var weatherImg    : String	// 天気画像
	var maxTemp: Double			// 最高気温
	// 最低気温
	var minTemp: Double
	
	init() {
		updateDate = NSDate()
		weatherCode = ""
		weatherImg = ""
		weather = ""
		weatherEng = ""
		maxTemp = 0
		minTemp = 0
	}
}

/*
struct WeatherData {

var weatherDate   : NSDate  // お天気の日時
var updateDate    : NSDate	// 更新日時
var weather       : String	// 天気（日本語）
var weatherEng    : String	// 天気（英語）
var weatherCode   : String	// 天気コード
var weatherImg    : String	// 天気画像
var maxTemp		  : Double  // 最高気温
var minTemp       : Double  // 最低気温
var temp		  : Double  // 気温

init() {
weatherDate    = NSDate()
updateDate     = NSDate()
weather        = ""
weatherEng     = ""
weatherCode    = ""
weatherImg     = ""
maxTemp		   = 0
minTemp		   = 0
temp		   = 0
}

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

*/

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
