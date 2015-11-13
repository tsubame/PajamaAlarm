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
	

	@IBOutlet weak var _sampleDialogUIView: UIView!
	
	// アラームセット用ダイアログ
	var _alarmDialog: AlarmTimePickersUIView!
	

	
	
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

	/*
	// ダイアログの生成
	func makeAlarmDialog() {
		// オートレイアウト
		let autoLayout = AutoLayoutHelper()
		autoLayout.addAutoLayoutSizing(_alarmDialog, toItem: _sampleDialogUIView, wRatio: 0.8, hRatio: 0.8)
		autoLayout.addAutoLayoutCentering(_alarmDialog, toItem: _sampleDialogUIView, centerX: true, centerY: true)
	}*/
	

	
	//======================================================
	// Action
	//======================================================
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		//
	}
	
	@IBAction func backToHome(segue: UIStoryboardSegue) {
		changeFacialEx("笑")
	}
	
	//======================================================
	// UI
	//======================================================
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//startBlink()
		
		//_charaImageView.tag = 10
		//_charaImageView.userInteractionEnabled = true
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		//playVoice()
	}
	
	

}

