//
//  ConstantsAndFunctions.swift
//  定数、関数定義用ファイル
//
//  Created by hideki on 2014/11/03.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import UIKit


//======================================================
// プリファレンス
//======================================================

let PREF_KEY_ALARM_TIME   = "alarmTime"  // 設定情報のキー アラーム時刻
let PREF_KEY_IS_ALARM_SET = "isAlarmSet" // アラームがセットされているか Bool型

//======================================================
// 通知センター　（ローカル通知）
//======================================================

let LOCAL_NOTIF_BODY   = "アラームの時間です" // ローカル通知メッセージ
let LOCAL_NOTIF_ACTION = "アプリを起動"	   // ローカル通知アクション

let LOCAL_NOTIF_SOUND  = "koron.wav"

//======================================================
// 通知センター
//======================================================


let NOTIF_SET_ALARM_ON  = "setAlarmOn"  // アラームがセットされた
let NOTIF_SET_ALARM_OFF = "setAlarmOff" // アラームがオフになった
let NOTIF_START_ALARM   = "startAlarm"  // アラームスタート
let NOTIF_STOP_ALARM    = "stopAlarm"   // アラームストップ

let NOTIF_START_MORNING_VOICE = "startMorningVoice"   // おはようボイススタート
let NOTIF_PLAY_GREETING_VOICE = "playGreetingVoice"  // 挨拶
/*
// アラーム直前
let NOTIF_JUST_BEFORE_ALARM = "justBeforeAlarm"
// アラームセットダイアログの表示
let NOTIF_SHOW_ALARM_DIALOG = "showAlarmDialog"

// サウンドをすべて一時停止
let NOTIF_PAUSE_ALL_SOUND  = "pauseAllSound"
// サウンドをすべて再開
let NOTIF_RESUME_ALL_SOUND = "resumeAllSound"
// サウンドをすべて停止
let NOTIF_STOP_ALL_SOUND = "stopAllSound"
*/

//======================================================
// アラーム関連
//======================================================

// ダミーで流す無音サウンド
let MUTE_SOUND_FILENAME = "nosound.mp3"
// サウンド
let ALARM_SOUND = "kirakira"

let SET_ALARM_MINUTE_INTERVAL = 2

//======================================================
// その他
//======================================================

// カレンダー
let CALENDAR = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!




//===========================================================
// トップレベルで使える関数
//===========================================================

// Double型を指定できる dispatch_after   （使い方）dispatchAfterByDouble(2.0, { println("test.") })
func dispatchAfterByDouble(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

// 乱数取得
func rand(num: Int) -> Int {
    var result:Int
    result = Int(arc4random() % UInt32(num))
    
    return result
}

// ImageViewを作成
func makeImageView(frame: CGRect, image: UIImage) -> UIImageView {
    let imageView = UIImageView()
    imageView.frame = frame
    imageView.image = image
    
    return imageView
}

//UIntに16進で数値をいれるとUIColorが戻る関数　例: view.backgroundColor = UIColorFromRGB(0x123456)
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
	return UIColor(
		red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
		green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
		blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
		alpha: CGFloat(1.0)
	)
}

// プリファレンスに書き込み
func writePref(object: NSObject, key: String) {
	let pref = NSUserDefaults.standardUserDefaults()
	pref.setObject(object, forKey: key)
	pref.synchronize()
}