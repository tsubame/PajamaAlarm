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
	
    var _volume: Float = 0.8
	var _playsVibe = true
	
    //var _loopCount     = 30
    //var _ringtone: String = ""
	
	var _alarmFile = "七咲逢-2.mp3"
	
    var _soundPlayer = SoundPlayer()
	
    var _timer: NSTimer?
	
	var _isPlaying = false
	
	
    // 初期化
    override init() {
        super.init()
		
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
    
    // アラームを鳴らす
    func startAlarm() {
        if _playsVibe == true {
            _timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "playVibe:", userInfo: nil, repeats: true)
        }
		
        _soundPlayer.play(_alarmFile)
		_isPlaying = true
    }
	
	// アラームが鳴っているか
	func isAlarmRinging() -> Bool {
		/*
		if _soundPlayer.isBgmPlaying() {
		return true
		}*/
		if _isPlaying == true {
			return true
		}
		
		return false
	}
	
    // バイブレーションスタート
    func playVibe(timer: NSTimer) {
        AudioServicesPlaySystemSound(1011)
        //AudioServicesPlaySystemSound(1352)
    }
	
	
    //
    func stopAlarm() {
        _timer?.invalidate()
        _timer = nil
		
		/*
        if _soundPlayer.isBgmPlaying() {
            _soundPlayer.playVoice(RESPOND_PHONE_SE)
            _soundPlayer.stopBgm()
            // 通知作成

            //NSNotificationCenter.defaultCenter().postNotificationName("startMorningCall", object: nil)
        }*/
		_soundPlayer.stopAll()
    }

}