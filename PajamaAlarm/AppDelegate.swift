//
//  AppDelegate.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/06.
//
//  初期化処理、起動時の処理などを担当
//
//  （依存クラス）
//  Constants.swift
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	// プライベート変数
	var _alarmTimeMonitor = AlarmTimeMonitor()
	var _alarmPlayer      = AlarmPlayer()
	var _locationGetter   = LocationGetter()
	var _weatherGetter    = WeatherGetter()
	
	// プリファレンスに初期データの登録
	func writeInitialDataToPref() {
		let pref = NSUserDefaults.standardUserDefaults()
		pref.setObject("兄さん", forKey: PREF_KEY_NICKNAME)
		pref.setObject("お姉ちゃん", forKey: PREF_KEY_NICKNAME)
		
		#if DEBUG
			print("位置情報を追加")
			let lat  = "32.74"
			let long = "129.87"
			pref.setObject(lat,  forKey: PREF_KEY_LATITUDE)
			pref.setObject(long, forKey: PREF_KEY_LONGITUDE)
		#endif
		
		pref.synchronize()
	}
	
	// 位置情報の更新
	func updateLocation() {
		_locationGetter.exec() { lat, long in
			if lat == nil || long == nil {
				return
			}
			
			writePref(lat,  key: PREF_KEY_LATITUDE)
			writePref(long, key: PREF_KEY_LONGITUDE)
		}
	}
	
	//======================================================
	// 天気関連
	//======================================================
	
	// 天気の更新
	func updateWeather() {
		print("お天気を取得します")
		_weatherGetter.exec() { dDatas in
			if dDatas.count == 0 {
				return
			}
			
			//self._todaysWeatherData = dDatas[0]
			self.writeWeatherToPref(dDatas[0])
			
			print(dDatas[0].weather)
		}
	}
	
	// 今日の天気をプリファレンスに保存
	func writeWeatherToPref(wData: WeatherData) {
		writeLastWeatherToPref()
		
		writePref(wData.weather,	 key: PREF_KEY_T_WEATHER)
		writePref(wData.minTemp,	 key: PREF_KEY_T_MIN_TEMP)
		writePref(wData.maxTemp,	 key: PREF_KEY_T_MAX_TEMP)
		writePref(wData.pop,		 key: PREF_KEY_T_POP)
		writePref(wData.weatherDate, key: PREF_KEY_T_WEATHER_DATE)
	}
	
	// 昨日の天気をプリファレンスに保存
	func writeLastWeatherToPref() {
		// プリファレンスのお天気データを取得
		let pwDate = readPref(PREF_KEY_T_WEATHER_DATE) as? NSDate
		print(pwDate)
		if pwDate == nil {
			return
		}
		
		// 昨日の日付なら保存
		let fmt        = NSDateFormatter()
		fmt.locale     = NSLocale(localeIdentifier: "ja")
		fmt.dateFormat = "yyyy-MM-dd"
		let y = fmt.stringFromDate(NSDate(timeIntervalSinceNow: -86400))
		let p = fmt.stringFromDate(pwDate!)
		
		if y == p {
			writePref(readPref(PREF_KEY_T_WEATHER)  as? String, key: PREF_KEY_Y_WEATHER)
			writePref(readPref(PREF_KEY_T_MIN_TEMP) as? Int,	key: PREF_KEY_Y_MIN_TEMP)
			writePref(readPref(PREF_KEY_T_MAX_TEMP) as? Int,	key: PREF_KEY_Y_MAX_TEMP)
			writePref(pwDate,  key: PREF_KEY_Y_WEATHER_DATE)
			
			print("昨日のお天気データを保存します")
		}
	}

	
	//======================================================
	// UIApplicationDelegate
	//======================================================
	
	// 起動時
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// 初期データの登録
		writeInitialDataToPref()
		
		// バックグラウンドオーディオ
		let player = SoundPlayer()
		player.backgroundAudioON()

		// 通知センターの使用許可
		application.registerUserNotificationSettings(UIUserNotificationSettings(
			forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert],
			categories: nil))
		// 位置情報
		
		addNotifObserver(NOTIF_UPDATE_LOCATION) {
			self.updateLocation()
		}
		addNotifObserver(NOTIF_UPDATE_WEATHER) {
			self.updateWeather()
		}
		
// ローカル通知を全て削除
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		
		return true
	}

	// フォアグラウンドに
	func applicationWillEnterForeground(application: UIApplication) {
		print("enter foreground.")
		
		if _alarmPlayer.isAlarmRinging() {
			_alarmPlayer.stopAlarm()
			NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_START_MORNING_VOICE, object: nil)
			
			return
		}
		
		// 挨拶
		NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_PLAY_GREETING_VOICE, object: nil)
	}
	
	func applicationWillResignActive(application: UIApplication) {

	}

	// バックグラウンドに入った時
	func applicationDidEnterBackground(application: UIApplication) {

	}



	func applicationDidBecomeActive(application: UIApplication) {

	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

