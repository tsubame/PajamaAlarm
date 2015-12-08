//
//  VoiceUtil.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/12/05.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit

class VoiceUtil: NSObject {
	let FACE_REGEX_PTN = "<(.+)>"	//
	
	/*
	var _soundPlayer = SoundPlayer()
	
	
	// 音声の再生
	func playVoice(voice: VoiceData) {
		if voice.fileName.isEmpty == false {
			_soundPlayer.play(voice.fileName)
		}
	}
	
	// 音声の停止
	func stopVoice() {
		_soundPlayer.stopAll()
	}*/
	
	// メッセージを2つに分割 ／ で句切られる
	func splitVoices(orgVoice: VoiceData) -> [VoiceData] {
		let splitChar = "／"
		var voices = [VoiceData]()
		
		let texts = orgVoice.text.componentsSeparatedByString(splitChar)
		for text in texts {
			var v  = VoiceData()
			v.text = text
			v      = getFacialExFromText(v)
			
			voices.append(v)
		}
		
		return voices
	}
	
	//======================================================
	// 表情関連
	//======================================================
	
	// テキストの中から表情パターンを取り出し、.face にセット。 <笑>のような形で入っている
	func getFacialExFromText(var vData: VoiceData) -> VoiceData {
		let nsText     = vData.text as NSString
		
		// 検索
		let reg = try? NSRegularExpression(pattern: FACE_REGEX_PTN, options: NSRegularExpressionOptions())
		let res = reg?.firstMatchInString(vData.text, options: NSMatchingOptions(), range: NSMakeRange(0, nsText.length))
		
		// 取り出し、置き換え
		if res != nil {
			vData.face = nsText.substringWithRange((res?.rangeAtIndex(1))!)
			vData.text = vData.text.stringByReplacingOccurrencesOfString(FACE_REGEX_PTN, withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		}
		
		return vData
	}
}
