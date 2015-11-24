//
//  ViewController.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/06.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
	
	@IBOutlet weak var _charaImageView  : UIImageView!
	@IBOutlet weak var _alarmButton     : UIButton!
	@IBOutlet weak var _voiceButton     : UIButton!
	@IBOutlet weak var _voiceFrameUIView: UIView!
	@IBOutlet weak var _voiceLabel      : UILabel!
	
	// プライベート変数
	var _morningVoiceManager = MorningVoiceManager()
	var _shortTalkManager    = ShortTalkManager()
	var _weatherGetter       = WeatherGetter()
	var _locationGetter      = LocationGetter()
	var _soundPlayer         = SoundPlayer()
	
	//var _currentWeatherName = ""
	var _todaysWeatherData = WeatherData()
	
	var _morningVoiceDatas = [VoiceData]()
	
	
	//======================================================
	// セリフの表示、再生
	//======================================================
	
	// セリフを枠内に表示、音声の再生
	func displayVoiceMsg(word: String, voiceFileName: String? = nil) {
		_voiceFrameUIView.hidden = false
		_voiceLabel.text = word

		if voiceFileName != nil {
			_soundPlayer.play(voiceFileName!)
		}
	}
	
	// 挨拶表示
	func displayGreeting() {
		let voiceData = _shortTalkManager.getGreetingVoiceData()
		if voiceData == nil {
			return
		}
		
		displayVoiceMsg(voiceData!.text)
	}
	
	// ひとこと表示
	func displayShortTalk() {
		if _voiceFrameUIView.hidden == false {
			_voiceFrameUIView.hidden = true
			_soundPlayer.stop()
			return
		}
		
		let vd = _shortTalkManager.getTalkVoiceData()
		if vd == nil {
			return
		}
		/*
		_voiceFrameUIView.hidden = false
		_voiceLabel.text = vd!.text
		changeFacialEx(vd!.face)
*/
		changeFacialEx("笑")
		displayVoiceMsg(vd!.text, voiceFileName: vd!.fileName)
	}
	
	// おはようボイスの表示
	func displayMorningVoice() {
		let voiceData = _morningVoiceDatas.removeFirst()
		let text = voiceData.text

		displayVoiceMsg(text)
	}
	
	//======================================================
	//
	//======================================================
	
	// 表情変更
	func changeFacialEx(facialEx: String? = nil) {
		var face = "笑"
		if facialEx != nil {
			face = facialEx!
		}
		
		switch face {
		case "笑":
			_charaImageView.image = UIImage(named: "hotaruS.png")
		default:
			_charaImageView.image = UIImage(named: "hotaruN.png")
		}
	}
	
	// 位置情報の更新
	func updateLocation() {
		_locationGetter.exec() { lat, long in
			if lat == nil || long == nil {
				return
			}
			
			writePref(lat,  key: PREF_KEY_LATITUDE)
			writePref(long, key: PREF_KEY_LATITUDE)
		}
	}

	// 天気の更新
	func updateWeather() {
		print("お天気を取得します")
		_weatherGetter.exec() { dDatas in
			//self._currentWeatherName = wData.weather
			if dDatas.count == 0 {
				return
			}
			
			self._todaysWeatherData  = dDatas[0]
			print(dDatas[0].weather)
		}
	}
	
	//======================================================
	// 初期処理
	//======================================================
	
	// UI部品のアスペクトを画面に合わせる
	func changeViewsAspectToFit() {
		_alarmButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		_voiceButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		self.view.setNeedsDisplay()
	}
	
	// オブザーバーの追加
	func addNotifObservers() {
		addNotifObserver(NOTIF_START_MORNING_VOICE) {
			self._morningVoiceDatas = self._morningVoiceManager.getMorningVoiceDatas(self._todaysWeatherData.weather)
			self.displayMorningVoice()
		}
		addNotifObserver(NOTIF_PLAY_GREETING_VOICE) {
			self.displayGreeting()
		}
		addNotifObserver(NOTIF_UPDATE_WEATHER) {
			self.updateWeather()
		}
		addNotifObserver(NOTIF_UPDATE_LOCATION) {
			self.updateLocation()
		}
	}
	
	//======================================================
	// セグエ
	//======================================================
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	
	}
	
	@IBAction func backToHome(segue: UIStoryboardSegue) {
		dispatchAfterByDouble(0.5, closure: {
			self.displayVoiceMsg("この時間に起こせばいいんだね？　了解です♪")
		})
	}
	
	//======================================================
	// UI
	//======================================================
	
	// ロード時に実行
	override func viewDidLoad() {
		super.viewDidLoad()
		
		changeViewsAspectToFit()
		addNotifObservers()
		
		dispatchAfterByDouble(0.5, closure: {
			self.displayGreeting()
		})
	}

	// タッチ
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if _morningVoiceDatas.isEmpty {
			displayShortTalk()
		} else {
			displayMorningVoice()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}

