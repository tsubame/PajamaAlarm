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

	
	// プリファレンスに初期データの登録
	func writeInitialDataToPref() {
		let pref = NSUserDefaults.standardUserDefaults()
		pref.setObject("兄さん", forKey: PREF_KEY_NICKNAME)

		#if DEBUG
			print("位置情報を追加")
			let lat  = "32.74"
			let long = "129.87"
			pref.setObject(lat,  forKey: PREF_KEY_LATITUDE)
			pref.setObject(long, forKey: PREF_KEY_LONGITUDE)
		#endif
		
		pref.synchronize()
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

