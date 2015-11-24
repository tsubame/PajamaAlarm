//
//  TimeMonitor.swift
//
//  アラームセット後、時刻を監視するクラス。
//
//  Created by hideki on 2014/11/05.
//  
//  （依存クラス）
//		Constants.swist, Functions.swift, SoundPlayer.swift
//
//  （処理内容）
//		1. アラームセットの通知を受け、時刻を監視するタイマーを起動
//		2. 無音ファイルをループ再生
//		3. 1分ごとに現在時刻とアラーム時刻を比較
//		4. 残り1分以内になったらカウントダウンを開始
//		5. 残り0秒になったらアラーム再生用の通知を発行
//		6. 天気取得用のローカル通知を発行
//

import UIKit
import Foundation

class AlarmTimeMonitor: NSObject {
	
	// 定数
    let MONITOR_TIMER_INTERVAL: Double = 60.0  // タイマーの実行インターバル（秒数）
	
	// プライベート変数
    var _monitorTimer  : NSTimer?    // 時刻監視用タイマー
    var _countDownTimer: NSTimer?    // カウントダウンタイマー
	var _alarmTime     : NSDate!     // アラームセット時間
	var _soundPlayer = SoundPlayer() // 無音サウンド再生用
	
	
    override init() {
        super.init()
		
		addNotifObserver(NOTIF_SET_ALARM_ON) {
			self.startBGTask()
		}
		addNotifObserver(NOTIF_SET_ALARM_OFF) {
			self.cancelAlarm()
		}
    }
	
	// アラームセット後、最初に行う処理。バックグラウンドで実行するタスクの開始
	func startBGTask() {
		_alarmTime = readPref(PREF_KEY_ALARM_TIME) as! NSDate
		
		// 無音ファイルを再生
		_soundPlayer.playMuteSound(MUTE_SOUND_FILENAME)
		
		// 時刻監視タイマーを起動
		_monitorTimer = NSTimer.scheduledTimerWithTimeInterval(MONITOR_TIMER_INTERVAL, target: self, selector: "checkCurrentTime:", userInfo: nil, repeats: true)
		checkCurrentTime(_monitorTimer!)
	}
	
	//======================================================
	// タイマー処理
	//======================================================
	
    // 現在時刻を確認し、アラーム時刻と比較
    func checkCurrentTime(timer: NSTimer) {
		// 差が60秒以内であればカウントダウン開始
		if compareTimeWithin60sec(_alarmTime) {
			startCountDown()
		}
	}
	
	// カウントダウンを開始。アラーム時刻まで残り1分以内の時の処理
	func startCountDown() {
		// 天気取得用のローカル通知を発行
		postLocalNotif(NOTIF_UPDATE_WEATHER)

		if isNowEqualsAlarmTime() {
			startAlarm()
			return
		}
		
		_countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countDown:", userInfo: nil, repeats: true)
	}
	
	// カウントダウン処理
	func countDown(timer: NSTimer) {
		let leftSecond = getCountdownSecFromCurrentTime()
		
		// カウントダウンが0になれば着信音を鳴らす
		if leftSecond == 0 {
			startAlarm()
		}
	}
	
	// タイマーストップ
	func stopAllTimer() {
		_monitorTimer?.invalidate()
		_countDownTimer?.invalidate()
	}
	
	//======================================================
	// アラーム処理
	//======================================================
	
	// アラームを鳴らす
	func startAlarm() {
		stopAllTimer()
		
		// 通知発行
		postLocalNotif(NOTIF_START_ALARM)
		
		dispatch_after(3, dispatch_get_main_queue(), {
			self._soundPlayer.stopMuteSound()
		})
		
		print("アラームの時間です。着信音を鳴らします")
	}
	
	// アラームキャンセル　オフにした時の処理
	func cancelAlarm() {
		stopAllTimer()
		
		// ローカル通知を全て削除
		UIApplication.sharedApplication().cancelAllLocalNotifications()
	}
	
	//======================================================
	// 時刻関連
	//======================================================
	
	// UNIXタイムスタンプを取得
	func getUnixTimestamp(date: NSDate) -> NSTimeInterval {
		let flags: NSCalendarUnit = [.Year, .Hour, .Minute, .Second]
		let comps = CALENDAR.components(flags, fromDate: date)
		let ts    = CALENDAR.dateFromComponents(comps)!.timeIntervalSince1970
		
		return ts
	}
	
    // 現在時刻がアラーム時刻かを判定
    func isNowEqualsAlarmTime() -> Bool {
		if compareHourAndMinute(NSDate(), date2: _alarmTime) {
			return true
		}

        return false
    }
	
	// NSDate型同士を比較して、時、分が同じかを判定
	func compareHourAndMinute(date1: NSDate, date2: NSDate) -> Bool {
		let flags: NSCalendarUnit = [.Hour, .Minute]

		let c1 = CALENDAR.components(flags, fromDate: date1)
		let c2 = CALENDAR.components(flags, fromDate: date2)

		if c1 == c2 {
			return true
		}
	
		return false
	}
	
	// 現在時刻とアラーム時刻を出力　デバッグ用
	func outputTimes(difSec: Int) {
		print("時刻監視用タイマー実行中...")
		
		let nTimeStr = getTimeStrFromDate(NSDate())
		let aTimeStr = getTimeStrFromDate(_alarmTime)
		
		print("　ただいまの時刻は\(nTimeStr)です。")
		print("　アラームの時刻は\(aTimeStr)です。")
		print("　残り\(difSec)秒")
	}
	
	// 時刻のみを文字列で取り出す （形式）"16:00"
	func getTimeStrFromDate(date: NSDate) -> String {
		let fmt        = NSDateFormatter()
		fmt.locale     = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
		fmt.dateFormat = "HH:mm"
		
		return fmt.stringFromDate(date)
	}
	
	//
	func compareTimeWithin60sec(date: NSDate) -> Bool {
		let nowTs   = getUnixTimestamp(NSDate())
		let alarmTs = getUnixTimestamp(date)
		let dSec    = Int(alarmTs - nowTs)
		
		outputTimes(dSec)
		
		// 差が60秒以内であればカウントダウン開始
		if -60 < dSec && dSec < 60 {
			return true
		}
		
		return false
	}
	
	// 現在時刻からカウントダウン用の秒を取得
	func getCountdownSecFromCurrentTime() -> Int {
		let flags: NSCalendarUnit = [.Hour, .Minute, .Second]
		let comps = CALENDAR.components(flags, fromDate: NSDate())
		
		// 60から現在の秒を引いた数を取得
		let leftSecond = (60 - comps.second) % 60
		if leftSecond % 5 == 0 {
			print("　\(leftSecond)")
		}
		
		return leftSecond
	}
	
	/*
    //===========================================================
    // AVAudioSessionDelegate
    //===========================================================

    func beginInterruption() {
        print("割り込まれましたぜ(｀・ω・´)")
    }
    
    func endInterruption() {
        print("割り込み終了")
    }*/
	
	
	
	
	
	/*
	// 時刻監視タイマーを起動し、無音ファイルを再生。アラームセット後、最初に行う処理
	func startTimeMonitoring() {
	_alarmTime = readPref(PREF_KEY_ALARM_TIME) as! NSDate
	
	// 無音ファイルを再生
	_soundPlayer.playMuteSound(MUTE_SOUND_FILENAME)
	
	_monitorTimer = NSTimer.scheduledTimerWithTimeInterval(MONITOR_TIMER_INTERVAL, target: self, selector: "checkCurrentTime:", userInfo: nil, repeats: true)
	checkCurrentTime(_monitorTimer!)
	}*/
	
}