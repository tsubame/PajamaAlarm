//
//  SetAlarmViewController.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/12.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit

class SetAlarmViewController: UIViewController {

	@IBOutlet weak var _timePickersView: AlarmTimePickersUIView!

	
	// アラーム用ローカル通知の作成
	func createScheduledLocalNotif(fireDate: NSDate) {
		let notif         = UILocalNotification()
		notif.fireDate    = fireDate    // NSDate(timeInterval: 5, sinceDate: NSDate()) //10秒後
		notif.hasAction   = true
		notif.timeZone    = NSTimeZone.defaultTimeZone()
		notif.soundName   = LOCAL_NOTIF_SOUND
		notif.alertBody   = LOCAL_NOTIF_BODY
		notif.alertAction = LOCAL_NOTIF_ACTION
		
		UIApplication.sharedApplication().scheduleLocalNotification(notif)
	}
	
	//======================================================
	// Action
	//======================================================
	
	@IBAction func _setButtonClicked(sender: AnyObject) {
		// プリファレンスに書き込み
		let alarmTime = _timePickersView.getAlarmTime()
		writePref(alarmTime!, key: PREF_KEY_ALARM_TIME)
		writePref("true", key: PREF_KEY_IS_ALARM_SET)
		
		// イベント通知の発行
		postLocalNotif(NOTIF_SET_ALARM_ON)
		postLocalNotif(NOTIF_UPDATE_LOCATION)
		
		// ローカル通知の発行
		createScheduledLocalNotif(alarmTime!)
	}
	
	//======================================================
	// UI
	//======================================================
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(animated: Bool) {
		//_timePickersView.alarmTimeToPicker()
		print("show pickers.")
		//print(readPref(PREF_KEY_ALARM_TIME))
		//_timePickersView.makeAll()
		//_timePickersView.movePickerIndex()
	}
}
