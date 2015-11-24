//
//  RingtonePlayer.swift
//  着信音再生用クラス
//
//  Created by hideki on 2014/11/05.
//  Copyright (c) 2014年 hideki. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class AlarmPlayer: NSObject {
	
	// 定数
	
	
	// プライベート変数
    var _volume: Float = 0.8
	var _isPlaying     = false
	var _soundPlayer   = SoundPlayer()
	
	// 以下、テスト用
	var _alarmFile = "alarm-1.mp3"
	var _playsVibe = true
	var _vibeTimer: NSTimer? // バイブレーション用 うまく動かない

	
    override init() {
        super.init()
		
		addNotifObserver(NOTIF_START_ALARM) {
			self.startAlarm()
		}
		addNotifObserver(NOTIF_STOP_ALARM) {
			self.stopAlarm()
		}
    }
    
    // アラームを鳴らす
    func startAlarm() {
        _soundPlayer.play(_alarmFile)
		_isPlaying = true
		
		// プリファレンスに書き込み
		writePref("false", key: PREF_KEY_IS_ALARM_SET)
	}
	
    // アラームの停止
    func stopAlarm() {
        _vibeTimer?.invalidate()
        _vibeTimer = nil
		_soundPlayer.stopAll()
		
		//NSNotificationCenter.defaultCenter().postNotificationName("startMorningCall", object: nil)
    }
	
	// アラームが鳴っているか
	func isAlarmRinging() -> Bool {
		return _isPlaying
	}
	
	// バイブレーション
	func viberation(timer: NSTimer) {
		AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
	}
	
	func addObervers() {
		let notif = NSNotificationCenter.defaultCenter()
		
		notif.addObserverForName(NOTIF_START_ALARM, object: nil, queue: nil, usingBlock: {
			(notification: NSNotification!) in
			self.startAlarm()
		})
		
		notif.addObserverForName(NOTIF_STOP_ALARM, object: nil, queue: nil, usingBlock: {
			(notification: NSNotification!) in
			self.stopAlarm()
		})
	}

}