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
		let text = "おはよう。\n気持ちいい朝だね。"
		displayVoiceMsg(text)
	}
	
	func displaySampleGreeting() {
		let text = "あ、こんにちは。\n兄さん♪"
		displayVoiceMsg(text)
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

