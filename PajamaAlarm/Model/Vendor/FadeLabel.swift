//
//  FadeLabel.swift
//  EarClerics
//
//  Created by hideki on 2014/11/17.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
import UIKit

class FadeLabel: UILabel {
	
	// 定数
	let DEFAULT_DELAY_SECOND_TO_NEXT_CHAR  = 0.02 // デフォルト値
	let DEFAULT_CHAR_FADE_DURATION         = 0.8  // デフォルト値
	let DELAY_SECOND_TO_SHOW_1ST_CHAR	   = 0.06
	
	// プロパティ
	var delaySecondToNextChar = 0.0		// 次の文字を表示するまでの時間
	var charFadeDuration      = 0.0		// 1文字がフェードインする時間
	
	// プライベート変数
	var _labels = [UILabel]()			// ラベルの配列
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		sharedInit()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
		sharedInit()
	}
	
	// 初期化
	func sharedInit() {
		self.userInteractionEnabled = true
		delaySecondToNextChar = DEFAULT_DELAY_SECOND_TO_NEXT_CHAR
		charFadeDuration      = DEFAULT_CHAR_FADE_DURATION
		
		self.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
		self.layer.borderWidth = 0
	}
	
	// ラベルに文字を表示
	func show(text: String) {
		makeCharLabels(text)
		
		for (index, label) in _labels.enumerate() {
			label.hidden = true

			let delayTime = Double(index) * delaySecondToNextChar + DELAY_SECOND_TO_SHOW_1ST_CHAR
			delay(delayTime) {
				self.showSingleLabelWithFade(index)
			}
		}
	}
	
	func showWithFade() {
		let text = self.text
		if text == nil {
			return
		}
		
		makeCharLabels(text!)
		
		for (index, label) in _labels.enumerate() {
			label.hidden = true
			
			let delayTime = Double(index) * delaySecondToNextChar + DELAY_SECOND_TO_SHOW_1ST_CHAR
			delay(delayTime) {
				self.showSingleLabelWithFade(index)
			}
		}
	}
	
	//======================================================
	// ラベルの作成、表示
	//======================================================
	
	// ラベルの配列を作成
	func makeCharLabels(text: String) {
		clearLabels()
		_labels = [UILabel]()
		
		// ラベルを作成
		for (i, _) in text.characters.enumerate() {
			let label = makeLabel(CGPointMake(0, 0), text: text, font: self.font, index: i)
			self.addSubview(label)
			_labels.append(label)
		}
	}
	
	// ラベル、テキストを削除
	func clearLabels() {
		self.text = ""
		
		for label in _labels {
			label.removeFromSuperview()
		}
	}
	
	// 1つのラベルに1つの文字をフェード表示
	func showSingleLabelWithFade(index: Int) {
		
		if _labels.count <= index {
			return
		}
		
		let label = _labels[index]
		UIView.transitionWithView(label,
			duration: charFadeDuration,
			options: UIViewAnimationOptions.TransitionCrossDissolve,
			animations: {
				label.hidden = false
			},
			completion: {
				finished in

				if self._labels.count <= index + 1 {
					print("finished.")
				}
		})
	}

	// 1つのラベルを作成
	func makeLabel(pos: CGPoint, text: String, font: UIFont, index: Int) -> UILabel {
		let label = UILabel()
		
		label.frame         = CGRectMake(pos.x, pos.y, self.frame.width, self.frame.height)
		label.font          = font
		label.lineBreakMode = NSLineBreakMode.ByWordWrapping
		label.numberOfLines = 0
		label.textColor     = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
		
		let aText = NSMutableAttributedString(string: text)
		aText.addAttribute(NSForegroundColorAttributeName, value: self.textColor, range: NSMakeRange(index, 1))
		label.attributedText = aText
		//label.hidden = true
		label.sizeToFit()
		
		return label
	}
	
	// Double型を指定できる dispatch_after   （使い方）delay(2.0) { println("test.") }
	func delay(delaySec: Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delaySec * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
	
	
	
	
}