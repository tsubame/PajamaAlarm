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
	//@IBOutlet weak var _voiceFrameUIView: UIView!
	//@IBOutlet weak var _voiceLabel      : FadeLabel!//UILabel!
	//@IBOutlet weak var _voiceLabel: FadeLabel!
	
	@IBOutlet weak var _voiceLabel: FadeLabel!
	//@IBOutlet weak var _testLabel: FadeLabel!

	@IBOutlet weak var _weatherWindowUIView: UIView!
	@IBOutlet weak var _weatherWindowTimeLabel: UILabel!
	@IBOutlet weak var _weatherWindowDateLabel: UILabel!
	@IBOutlet weak var _weatherWindowTempLabel: UILabel!
	@IBOutlet weak var _weatherWindowIconImageView: UIImageView!
	
	@IBOutlet weak var _msgWindowUIView: UIView!
	//@IBOutlet weak var _msgWindowUIView: UIImageView!
	
	
	let _enableMouseMove = false
	
	// プライベート変数
	var _shortTalkBuilder = ShortTalkBuilder()	// ひとことデータ表示用
	var _soundPlayer	  = SoundPlayer()		// 音声再生用
	var _voiceDatas       = [VoiceData]()		// 表示するセリフデータ
	var _nowFaceImage	  = ""
	var _mouseMoveTimer: NSTimer?
	

	
	@IBAction func _testButtonClicked(sender: AnyObject) {
		startMouseMove()
	}


	//======================================================
	// セリフの表示、再生
	//======================================================
	
	// 次のセリフを表示
	func displayNextMsg() {
		stopMouseMove()
		startMouseMove()
		
		if !_voiceDatas.isEmpty {
			displayVoiceMsg(_voiceDatas.removeFirst())
		} else {
			delay(0.3) {
				self.hideMsgFrame()
			}
		}
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
			_soundPlayer.stopVoice()
			_soundPlayer.playVoices([v.fileName])
		}
	}
	
	//======================================================
	// 枠の表示、非表示
	//======================================================
	
	// 枠を非表示
	func hideMsgFrame() {
		changeFacialEx("通")
		animation(self.view, duration: 0.3, closure: {
			self._msgWindowUIView.hidden = true
		})

		_soundPlayer.stopAll()
		
		stopMouseMove()

		if self._voiceButton.hidden {
			animation(self.view, duration: 0.5, closure: {
				self._voiceButton.hidden = false
				self._alarmButton.hidden = false
				self._weatherWindowUIView.hidden = true
			})
		}
	}
	
	// 枠の表示、テキストの表示
	func showMsgInFrame(text: String? = nil) {
		_msgWindowUIView.hidden = false
		if text != nil {
			var str = text!
			for _ in 0...10 {
				str += "\n　"
			}
			str += "."
			
			/*
			var attr = _voiceLabel.attributedText
			attr = NSMutableAttributedString(string: str, attributes: attr?.attributesAtIndex(0, effectiveRange: nil))
			_voiceLabel.attributedText = attr
			*/
			_voiceLabel.show(text!)
			//_testLabel.show(text!)
		}

	}

	//======================================================
	// 挨拶、ひとこと、おはようボイスの表示
	//======================================================
	
	// 挨拶表示
	func displayGreeting() {
		_voiceDatas = _shortTalkBuilder.getGreetingDatas()
		
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
		
		if DEBUG_USE_FIXED_SOUND {
			while(true) {
				if _voiceDatas[0].fileName != DEBUG_FIXED_MORNING_VOICE {
					_voiceDatas = builder.exec(weather)
				} else {
					break
				}
			}
		}
		
		_alarmButton.hidden = true
		_voiceButton.hidden = true
		_weatherWindowUIView.hidden = false
		
		let fmt         = NSDateFormatter()
		fmt.dateFormat  = "MM/dd"
		_weatherWindowDateLabel.text = fmt.stringFromDate(NSDate())
		fmt.dateFormat  = "HH:mm"
		_weatherWindowTimeLabel.text = fmt.stringFromDate(NSDate())
		
		let minTemp = readPref(PREF_KEY_T_MIN_TEMP)
		let maxTemp = readPref(PREF_KEY_T_MAX_TEMP)
		
		if maxTemp != nil && minTemp != nil {
			let tempStr = "\(maxTemp!)°/\(minTemp!)°"
			_weatherWindowTempLabel.text = tempStr
		}
		
		//_weatherWindowDateLabel.text =
		
		if weather != nil {
			var icon = "豪雨"
			switch weather! {
				case "晴れ":
					icon = "晴れ"
				case "曇り":
					icon = "曇り"
				case "雨":
					icon = "雨"
				default:
					break
			}
			
			let imgName = "お天気アイコン-\(icon).png"
			_weatherWindowIconImageView.image = UIImage(named: imgName)
		}
		
		displayNextMsg()
	}
	
	//======================================================
	// 表情関連
	//======================================================
	
	// 表情変更
	func changeFacialEx(face: String) {
		
		switch face {
			case "笑":
				_nowFaceImage = "hotaruSML.png"
				_charaImageView.image = UIImage(named: _nowFaceImage)
			case "微笑":
				_nowFaceImage = "hotaruSML_2.png"
				_charaImageView.image = UIImage(named: _nowFaceImage)
			case "眠":
				_nowFaceImage = "hotaruSLP.png"
				_charaImageView.image = UIImage(named: _nowFaceImage)
			default:
				_nowFaceImage = "hotaruN.png"
				_charaImageView.image = UIImage(named: _nowFaceImage)
		}
	}
	
	//======================================================
	// 口パク
	//======================================================
	
	// 口パクテスト
	func moveMouse(timer: NSTimer) {
		let faces = ["hotaruSML.png", "hotaruSML_1.png", "hotaruSML_2.png"]
		let r = rand(faces.count - 1)
		let face = faces[r]
		
		if face == _nowFaceImage {
			moveMouse(timer)
		} else {
			_nowFaceImage = face
			_charaImageView.image = UIImage(named: face)
		}
	}
	
	func startMouseMove() {
		if !_enableMouseMove {
			return
		}
		let timerInterval = 0.2
		_mouseMoveTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "moveMouse:", userInfo: nil, repeats: true)
	}
	
	func stopMouseMove() {
		_mouseMoveTimer?.invalidate()
		//changeFacialEx("笑")
		_charaImageView.image = UIImage(named: "hotaruSML_2.png")
	}
	
	//======================================================
	// UIKit関連
	//======================================================
	
	// UI部品のアスペクトを画面に合わせる
	func changeViewsAspectToFit() {
		_alarmButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		_voiceButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
		self.view.setNeedsDisplay()
	}
	
	func makeMsgWindow() {

		/*
		var aText = NSMutableAttributedString(string: _voiceLabel.text!)//_voiceLabel.attributedText
		//let attrs = aText.attributesAtIndex(0, effectiveRange: nil)
		let pStyle = NSMutableParagraphStyle()
		pStyle.lineHeightMultiple = 1.5
		//pStyle.headIndent = 18
		aText.addAttribute(NSParagraphStyleAttributeName, value: pStyle, range: NSMakeRange(0, aText.length))

		_voiceLabel.attributedText = aText
		_voiceLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
		//_voiceLabel.outlineColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
		//_voiceLabel.outlineSize = 0.0
		
		_voiceLabel.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
		_voiceLabel.layer.borderWidth = 0
		_msgWindowUIView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
		_msgWindowUIView.layer.borderWidth = 0
		//_voiceLabel.layer.
		
		//NSMutableAttributedString(string: <#T##String#>, attributes: <#T##[String : AnyObject]?#>)
		//_voiceLabel.removeFromSuperview()
		//_msgWindowUIView.addSubview(_voiceLabel)

		let helper = AutoLayoutHelper()
		//helper.addAutoLayoutSizing(_voiceLabel, toItem: _msgWindowUIView, wRatio: 0.9, hRatio: 0.5)
		helper.addAutoLayoutCentering(_voiceLabel, toItem: _msgWindowUIView)
*/
	}
	
	//func makeLabel(pos: CGPoint, text: String, font: UIFont? = nil) -> UILabel {
	/*
	func makeLabel() -> UILabel {
		let label = UILabel()
		label.frame = CGRectMake(30, 40, 250, 100)
		label.numberOfLines = 0
		label.sizeToFit()
		
		_voiceLabel.layer.borderColor = UIColor.grayColor().CGColor
		_voiceLabel.layer.borderWidth = 1.0
		_voiceLabel.layer.cornerRadius = 4.0
		
		return label
	}*/
	
	//======================================================
	// Action
	//======================================================
	
	@IBAction func _alarmButtonClicked(sender: AnyObject) {
		//var voice = VoiceData()
		//voice.text = ""
		//voice.face = ""
		//voice.fileName = "めざましセット_0.mp3"
		//self.displayVoiceMsg(voice)
		//_soundPlayer.playVoices(["めざましセット_0.mp3"])
	}
	
	//======================================================
	// UI
	//======================================================
	
	// ロード時に実行
	override func viewDidLoad() {
		super.viewDidLoad()

		// メッセージウィンドウ
		makeMsgWindow()
		// アスペクトを画面に合わせる
		changeViewsAspectToFit()

		_weatherWindowUIView.hidden = true
		
		// オブザーバーの追加
		addNotifObserver(NOTIF_START_MORNING_VOICE) {
			self.displayMorningVoice()
		}
		addNotifObserver(NOTIF_PLAY_GREETING_VOICE) {
			self.displayGreeting()
		}
		addNotifObserver("voicePlayEnded") {
			self.displayNextMsg()
		}
		
		// 挨拶データの表示
		delay(0.5, closure: {
			self.displayGreeting()
		})
	}
	
	// タッチイベント
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if _voiceDatas.isEmpty && _msgWindowUIView.hidden == false {
			hideMsgFrame()
			return
		}
		
		if !_voiceDatas.isEmpty {
			displayNextMsg()
		} else {
			displayShortTalk()
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		// 1stレスポンダーに
		if self.canBecomeFirstResponder() {
			self.becomeFirstResponder()
			UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
		}
	}
	


	// 回転の許可
	override func shouldAutorotate() -> Bool {
		return false
	}

	// 1stレスポンダー
	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	//===========================================================
	// RemoteControl
	//===========================================================

	override func remoteControlReceivedWithEvent(event: UIEvent?) {
		print(event)
		
		if event == nil {
			return
		}
		
		if (event!.type == UIEventType.RemoteControl) {
			
			switch event!.subtype {
				// 再生ボタン
			case UIEventSubtype.RemoteControlPlay:
				NSNotificationCenter.defaultCenter().postNotificationName("", object: nil)
				break
				// 一時停止ボタン
			case UIEventSubtype.RemoteControlPause:
				NSNotificationCenter.defaultCenter().postNotificationName("", object: nil)
				break
			case UIEventSubtype.RemoteControlTogglePlayPause:
				break
			default:
				break
			}
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
			voice.text = "「この時間に起こせばいいんだね？　了解です♪」"
			voice.face = "笑"
			voice.fileName = "めざましセット_1.mp3"
			self.displayVoiceMsg(voice)
		})
	}
	
}

