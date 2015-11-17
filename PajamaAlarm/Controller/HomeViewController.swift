//
//  ViewController.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/06.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
	
	@IBOutlet weak var _charaImageView: UIImageView!
	
	@IBOutlet weak var _alarmButton: UIButton!
	
	@IBOutlet weak var _voiceButton: UIButton!

	@IBOutlet weak var _voiceFrameUIView: UIView!
	
	var _shortTalkManager = ShortTalkManager()
	
	@IBOutlet weak var _voiceLabel: UILabel!
	
	var _weatherGetter = WeatherGetter()
	
	var _currentWeatherName = ""
	var _todaysWeatherName = ""
	
	//
	func checkBlink() {
		// ランダムで瞬き
		if rand(6) == 0 {
			//blink()
		}
	}
	
	// 表情変更
	func changeFacialEx(facialEx: String) {
		switch facialEx {
			case "笑":
				_charaImageView.image = UIImage(named: "hotaruS.png")
			default:
				_charaImageView.image = UIImage(named: "hotaruN.png")
		}
	}
	
	// セリフ表示
	func displayVoiceMsg(word: String) {
		_voiceFrameUIView.hidden = false
		_voiceLabel.text = word
		changeFacialEx("笑")
	}
	
	func displaySampleMsg() {
		let text = "おはよう。\n現在の天気は\(_currentWeatherName)、今日は\(_todaysWeatherName)の予報になってるよ。"
		displayVoiceMsg(text)
	}
	
	func displaySampleGreeting() {
		let text = "あ、こんにちは。\n兄さん♪"
		displayVoiceMsg(text)
	}
	
	func updateWeather() {
		_weatherGetter.updateWeather( { wData, dDatas in
			print(wData.weather)
			self._currentWeatherName = wData.weather
			self._todaysWeatherName  = dDatas[0].weather
		})
	}
	
	//======================================================
	// Action
	//======================================================
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		//
	}
	
	@IBAction func backToHome(segue: UIStoryboardSegue) {
		dispatchAfterByDouble(0.5, closure: {
			self.displayVoiceMsg("この時間に起こせばいいんだね？　了解です♪")
		})
	}
	
	//======================================================
	// UI
	//======================================================
	
	override func viewDidLoad() {
		super.viewDidLoad()

		_alarmButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		_voiceButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		
		let nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
		
		nc.addObserverForName(NOTIF_START_MORNING_VOICE, object: nil, queue: nil, usingBlock: {
			(notification: NSNotification!) in
			self.displaySampleMsg()
		})
		nc.addObserverForName(NOTIF_PLAY_GREETING_VOICE, object: nil, queue: nil, usingBlock: {
			(notification: NSNotification!) in
			self.displaySampleGreeting()
		})
		nc.addObserverForName(NOTIF_UPDATE_WEATHER, object: nil, queue: nil, usingBlock: {
			(notification: NSNotification!) in
			self.updateWeather()
		})
		
		self.view.setNeedsDisplay()
		
		dispatchAfterByDouble(0.5, closure: {
			self.displaySampleGreeting()
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if _voiceFrameUIView.hidden == false {
			_voiceFrameUIView.hidden = true
			changeFacialEx("")
			
			return
		}
		
		let txt = _shortTalkManager.getTalkText()
		_voiceFrameUIView.hidden = false
		_voiceLabel.text = txt
		changeFacialEx("笑")
		print(txt)
	}


}

