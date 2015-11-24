//
//  Constants.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/18.
//
//	アプリケーション共通の定数
//

import Foundation
import UIKit

//======================================================
// プリファレンス
//======================================================

let PREF_KEY_ALARM_TIME   = "alarmTime"  // 設定情報のキー アラーム時刻
let PREF_KEY_IS_ALARM_SET = "isAlarmSet" // アラームがセットされているか Bool型

let PREF_KEY_LATITUDE  = "latitude"
let PREF_KEY_LONGITUDE = "longitude"

let PREF_KEY_NICKNAME  = "nickName"		 // ほたるからの呼び名

//let NOTIF_UPDATE_WEATHER = "updateWeather"


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

let NOTIF_UPDATE_WEATHER  = "updateWeather"
let NOTIF_UPDATE_LOCATION = "updateLocation"

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

// エラーメッセージ
let ERROR_MSG = "== ERROR!! == "

// Documentsへのパス
let PATH_TO_DOCUMENTS = (NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString


let ERROR_MSG_PREFIX = "=== error! === "

let NICKNAMES        = ["兄さん", "お姉ちゃん"]
