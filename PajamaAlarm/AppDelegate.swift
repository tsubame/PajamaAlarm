//
//  AppDelegate.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/06.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	var _alarmTimeMonitor = AlarmTimeMonitor()
	var _alarmPlayer      = AlarmPlayer()
	
	var _g: LocationGetter!
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		// バックグラウンドオーディオ
		let player = SoundPlayer()
		player.backgroundAudioON()

		application.registerUserNotificationSettings(UIUserNotificationSettings(
			forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert],
			categories: nil))
		
		writePref("兄さん", key: PREF_KEY_NICKNAME)
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
		print("enter foreground.")
		
		if _alarmPlayer.isAlarmRinging() {
			_alarmPlayer.stopAlarm()
			NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_START_MORNING_VOICE, object: nil)
			
			return
		}
		
		// 挨拶
		NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_PLAY_GREETING_VOICE, object: nil)
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		//print("become active.")
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

