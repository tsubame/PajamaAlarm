//
//  ViewController.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/06.
//
//	（説明）
//		ホーム画面のコントローラクラス。
//
//  （依存ファイル）
//		・Constants.swift
//		・Functions.swift
//		・MorningVoiceManager.swift
//		・ShortTalkManager.swift
//		・WeatherGetter.swift
//		・LocationGetter.swift
//		・VoicePlayer.swift
//

import UIKit

class HomeViewController: UIViewController {
	
	@IBOutlet weak var _charaImageView  : UIImageView!
	@IBOutlet weak var _alarmButton     : UIButton!
	@IBOutlet weak var _voiceButton     : UIButton!
	@IBOutlet weak var _voiceFrameUIView: UIView!
	@IBOutlet weak var _voiceLabel      : UILabel!
	
	// プライベート変数
	var _shortTalkBuilder = ShortTalkBuilder()
	var _soundPlayer	  = SoundPlayer()
	var _voiceDatas       = [VoiceData]()		// 表示するセリフデータ
	
	
	//======================================================
	// UIKitのアスペクトの変更
	//======================================================
	
	// UI部品のアスペクトを画面に合わせる
	func changeViewsAspectToFit() {
		_alarmButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		_voiceButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		self.view.setNeedsDisplay()
	}

	//======================================================
	// セリフの表示、再生
	//======================================================
	
	// 次のセリフを表示
	func displayNextMsg() {
		displayVoiceMsg(_voiceDatas.removeFirst())
	}
	
	// セリフを枠内に表示、音声の再生
	func displayVoiceMsg(var v: VoiceData) {
		if v.face.isEmpty {
			v.face = "笑"
		}
		
		changeFacialEx(v.face)
		showMsgInFrame(v.text)
		
		// 音声の再生
		if v.fileName.isEmpty == false {
			_soundPlayer.play(v.fileName)
		}
	}
	
	//======================================================
	// 枠の表示、非表示
	//======================================================
	
	// 枠を非表示
	func hideMsgFrame() {
		_voiceFrameUIView.hidden = true
		_soundPlayer.stopAll()
		changeFacialEx("通")
	}
	
	// 枠の表示、テキストの表示
	func showMsgInFrame(text: String? = nil) {
		_voiceFrameUIView.hidden = false
		
		if text != nil {
			_voiceLabel.text = text!
		}
	}

	//======================================================
	// 挨拶、ひとこと、おはようボイスの表示
	//======================================================
	
	// 挨拶表示
	func displayGreeting() {
		let builder = ShortTalkBuilder()
		_voiceDatas = builder.getGreetingDatas()
		
		changeFacialEx("笑")
		displayNextMsg()
	}
	
	// ひとこと表示
	func displayShortTalk() {
		_voiceDatas = _shortTalkBuilder.getShortTalkDatas()

		displayNextMsg()
	}
	
	// おはようボイスの表示
	func displayMorningVoice() {
		let builder = MorningVoiceBuilder()
		let weather = readPref(PREF_KEY_T_WEATHER) as? String
		_voiceDatas = builder.exec(weather)
		
		displayNextMsg()
	}
	
	//======================================================
	// 表情関連
	//======================================================
	
	// 表情変更
	func changeFacialEx(face: String) {
		switch face {
			case "笑":
				_charaImageView.image = UIImage(named: "hotaruS.png")
			case "眠":
				_charaImageView.image = UIImage(named: "hotaruSLP.png")
			default:
				_charaImageView.image = UIImage(named: "hotaruN.png")
		}
	}
	
	//======================================================
	// UI
	//======================================================
	
	// ロード時に実行
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// アスペクトを画面に合わせる
		changeViewsAspectToFit()
		// オブザーバーの追加
		addNotifObserver(NOTIF_START_MORNING_VOICE) {
			self.displayMorningVoice()
		}
		addNotifObserver(NOTIF_PLAY_GREETING_VOICE) {
			self.displayGreeting()
		}
		
		// 挨拶データの表示
		delay(0.5, closure: {
			self.displayGreeting()
		})
	}
	
	// タッチイベント
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if _voiceDatas.isEmpty && _voiceFrameUIView.hidden == false {
			hideMsgFrame()
			return
		}
		
		if !_voiceDatas.isEmpty {
			displayNextMsg()
		} else {
			displayShortTalk()
		}
	}
	
	//======================================================
	// セグエ
	//======================================================
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		//
	}
	
	@IBAction func backToHome(segue: UIStoryboardSegue) {
		delay(0.5, closure: {
			var voice = VoiceData()
			voice.text = "この時間に起こせばいいんだね？　了解だよ♪"
			voice.face = "笑"
			self.displayVoiceMsg(voice)
		})
	}
	
}

