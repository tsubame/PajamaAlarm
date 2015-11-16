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
	func createLocalNotif(fireDate: NSDate) {
		let notif         = UILocalNotification()
		notif.fireDate    = fireDate    // NSDate(timeInterval: 5, sinceDate: NSDate()) //10秒後
		notif.hasAction   = true
		notif.timeZone    = NSTimeZone.defaultTimeZone()
		notif.soundName   = LOCAL_NOTIF_SOUND
		notif.alertBody   = LOCAL_NOTIF_BODY
		notif.alertAction = LOCAL_NOTIF_ACTION
		
		UIApplication.sharedApplication().scheduleLocalNotification(notif)
		
		print(fireDate)
	}
	
	//======================================================
	// Action
	//======================================================
	
	@IBAction func _setButtonClicked(sender: AnyObject) {
		let alarmTime = _timePickersView.getAlarmTime()
		writePref(alarmTime!, key: PREF_KEY_ALARM_TIME)
		
		//let pref = NSUserDefaults.standardUserDefaults()
		//pref.setObject(alarmTime, forKey: PREF_KEY_ALARM_TIME)
		//pref.synchronize()
		
		// イベント通知の発行
		NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_SET_ALARM_ON, object: nil)
		// ローカル通知の発行
		createLocalNotif(alarmTime!)
	}
	
	//======================================================
	// UI
	//======================================================
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(animated: Bool) {
		//_timePickersView.alarmTimeToPicker()
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
