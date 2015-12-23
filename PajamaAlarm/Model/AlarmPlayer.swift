//
//  AlarmPlayer.swift
//
//  Created by hideki on 2015/11/05.
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
	var _alarmFile1 = "めざましボイス_0.mp3" //"alarm-1.mp3"
	var _alarmFile2 = "alarm-2.mp3"
	var _alarmFile3 = "alarm-3.mp3"
	
	var _playsVibe = true
	var _vibeTimer: NSTimer? // バイブレーション用 うまく動かない

	var _alarmFiles = ["めざましボイス_2.mp3", "alarm-2.mp3", "alarm-3.mp3"]
	var _alarmIndex = 0
	
	var _snoozeTimer: NSTimer?
	
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
		_soundPlayer.play(_alarmFiles[_alarmIndex], ch: _alarmIndex, volume: 0.7, loop: true)
		_isPlaying = true
		_snoozeTimer = NSTimer.scheduledTimerWithTimeInterval(110, target: self, selector: "snooze:", userInfo: nil, repeats: true)
				
		// プリファレンスに書き込み
		writePref("false", key: PREF_KEY_IS_ALARM_SET)
		
		// テスト用
		let imgName = "album.png"
		let path = NSBundle.mainBundle().pathForResource(imgName, ofType: "")
		
		if path != nil {
			print("■ 画像のパスは……")
			print(path)
			_soundPlayer.showInfoToControleCenter("目覚ましボイス", imgName: path)
		}
	}
	
	func snooze(timer: NSTimer?) {
		if _alarmFiles.count <= _alarmIndex + 1 {
			_snoozeTimer?.invalidate()
			_snoozeTimer = nil
			self._soundPlayer.stopAll()
			_alarmIndex = 0
			
			return
		}
		
		self._soundPlayer.play(_alarmFiles[_alarmIndex + 1], ch: _alarmIndex + 1, volume: 1, loop: true)
		self._soundPlayer.stop(_alarmIndex)
		_alarmIndex++
	}
	
	
    // アラームの停止
    func stopAlarm() {
		_snoozeTimer?.invalidate()
		_snoozeTimer = nil
		_soundPlayer.stopAll()
		_isPlaying = false
		
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