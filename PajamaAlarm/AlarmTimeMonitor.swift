//
//  TimeMonitor.swift
//  アラームセット時に時刻を監視するクラス
//
//  Created by hideki on 2014/11/05.
//  Copyright (c) 2014年 hideki. All rights reserved.
//


import UIKit
import Foundation
import AVFoundation

class AlarmTimeMonitor: NSObject {
    
	
    let MONITOR_TIMER_INTERVAL: Double = 60.0 // タイマーの実行インターバル　（秒数）
	
    //var _pref = NSUserDefaults.standardUserDefaults() // 設定情報
    var _monitorTimer: NSTimer?      // 時刻監視用タイマー
    var _countDownTimer: NSTimer?    // カウントダウンタイマー
    var _soundPlayer = SoundPlayer() // サウンド再生用

	var _alarmTime: NSDate!
	
    // 初期化
    override init() {
        super.init()

        let nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        nc.addObserverForName(NOTIF_SET_ALARM_ON, object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.startTimeMonitoring()
        })
        nc.addObserverForName(NOTIF_SET_ALARM_OFF, object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.cancelAlarm()
        })
    }
	
	// 監視用タイマー起動
	func startTimeMonitoring() {
		_alarmTime = NSUserDefaults.standardUserDefaults().objectForKey(PREF_KEY_ALARM_TIME) as! NSDate
		self.cancelAlarm()
		
		// 無音ファイルを再生
		_soundPlayer.playMuteSound(MUTE_SOUND_FILENAME)
		
		// タイマーを起動
		_monitorTimer = NSTimer.scheduledTimerWithTimeInterval(MONITOR_TIMER_INTERVAL, target: self, selector: "compareTimes:", userInfo: nil, repeats: true)
		compareTimes(_monitorTimer!)
		
		// 位置情報の取得
		//NSNotificationCenter.defaultCenter().postNotificationName("startUpdateLocation", object: nil)
	}
	
	//======================================================
	// タイマー処理
	//======================================================
	
    // 現在時刻を確認し、アラーム時刻と比較。
    func compareTimes(timer: NSTimer) {
		printNowTimeAndAlarmTime()

		let nowTs   = getTimestamp(NSDate())
		let alarmTs = getTimestamp(_alarmTime)
		let difSec  = Int(alarmTs - nowTs)
		print("　残り\(difSec)秒")
		
		// 差が60秒以内であればカウントダウン開始
		if -60 < difSec && difSec < 60 {
			startCountDown()
		}
	}
	
	// カウントダウン開始
	func startCountDown() {
		_monitorTimer?.invalidate()
		_monitorTimer = nil
		
		if isNowEqualsAlarmTime() {
			startAlarm()
			
			return
		}
		
		_countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countDown:", userInfo: nil, repeats: true)
	}
	
	// カウントダウン処理
	func countDown(timer: NSTimer) {
		// 現在の秒を取得
		let flags: NSCalendarUnit = [.Hour, .Minute, .Second]
		let cal    = CALENDAR
		let comps  = cal.components(flags, fromDate: NSDate())
		let second = comps.second
		
		// 60から現在の秒を引いた数を取得
		let leftSecond = (60 - second) % 60
		// カウントダウンが0になれば着信音を鳴らす
		if leftSecond == 0 {
			startAlarm()
		}
		
		print("　\(leftSecond)")
	}
	
	//======================================================
	// 時刻関連
	//======================================================
	
	// タイムスタンプを取得
	func getTimestamp(date: NSDate) -> NSTimeInterval {
		let flags: NSCalendarUnit = [.Year, .Hour, .Minute, .Second]
		let cal = CALENDAR
		
		let comps = cal.components(flags, fromDate: date)
		let ts    = cal.dateFromComponents(comps)!.timeIntervalSince1970
		
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
		let cal = CALENDAR
		
		let c1 = cal.components(flags, fromDate: date1)
		let c2 = cal.components(flags, fromDate: date2)

		if c1 == c2 {
			return true
		}
	
		return false
	}
	
	// 現在時刻とアラーム時刻をprint
	func printNowTimeAndAlarmTime() {
		print("時刻監視用タイマー実行中...")
		
		let nTimeStr = getTimeStrFromDate(NSDate())
		let aTimeStr = getTimeStrFromDate(_alarmTime)
		
		print("　ただいまの時刻は\(nTimeStr)です。")
		print("　アラームの時刻は\(aTimeStr)です。")
	}
	
	// 時刻のみを文字列で取り出す （形式）"16:00"
	func getTimeStrFromDate(date: NSDate) -> String {
		let fmt    = NSDateFormatter()
		fmt.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
		fmt.dateFormat = "HH:mm"
		
		return fmt.stringFromDate(date)
	}
	
	//======================================================
	// アラーム処理
	//======================================================
	
    // アラームを鳴らす
    func startAlarm() {
        // カウントダウンタイマーを停止
        _countDownTimer?.invalidate()
        _countDownTimer = nil
		
        // 通知発行
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIF_START_ALARM, object: nil)
        //NSNotificationCenter.defaultCenter().postNotificationName("showRingingView", object: nil)
		
        // アラームのセットをオフに
        let pref = NSUserDefaults.standardUserDefaults()
        pref.setObject("false", forKey: PREF_KEY_IS_ALARM_SET)
        pref.synchronize()
		
        dispatch_after(3, dispatch_get_main_queue(), {
            self._soundPlayer.stopMuteSound()
        })
		
		print("アラームの時間です。着信音を鳴らします")
    }
    
    // アラームキャンセル　オフにした時の処理
    func cancelAlarm() {
        //print("アラームをキャンセル")
        /* if _alarmPlayer.playing {
			_alarmPlayer.stop()
        }*/
        
        _monitorTimer?.invalidate()
        _monitorTimer = nil
        _countDownTimer?.invalidate()
        _countDownTimer = nil
        //print("1、2つ目のタイマーを停止しました")
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    //===========================================================
    // AVAudioSessionDelegate
    //===========================================================

    func beginInterruption() {
        print("割り込まれましたぜ(｀・ω・´)")
    }
    
    func endInterruption() {
        print("割り込み終了")
    }
	

	
}