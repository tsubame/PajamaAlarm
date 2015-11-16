//
//  ShortTalkManager.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/16.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit

class ShortTalkManager: NSObject {

	// 定数
	let TEXT_FILE_NAME = "sample-utf8.txt"		// 台本のファイル名
	let ENCODING       = NSUTF8StringEncoding	// エンコーディング
	
	
	var _allVoiceWords = ["朝": ["「セリフ1」", "「セリフ2」"]] //[String: [String]]()
	var _sectionName   = ""
	
	var _voiceWords = [String]()
	var _voiceIndex = 0
	
	
	let KEYS = ["朝", "お昼", "夜", "雨の日", "その他", "眠そうな声"]

	
	override init() {
		super.init()
		
		//loadTextFile()
		loadTextFileAndSplit()
		print(_allVoiceWords)
		let sec = getSectionFromTime()
		let words = _allVoiceWords[sec]!
		_voiceWords = words + _allVoiceWords["その他"]!
	}
	
	// 
	func getTalkText() -> String {
		let txt = _voiceWords[_voiceIndex]
		
		_voiceIndex++
		if _voiceWords.count <= _voiceIndex {
			_voiceIndex = 0
		}
		
		return txt
	}
	
	func getSectionFromTime() -> String {
		var sec = "その他"
		
		let flags: NSCalendarUnit = [.Hour]
		let cal   = CALENDAR
		let comps = cal.components(flags, fromDate: NSDate())
		let hour  = comps.hour
		
		switch hour {
			case(6...11):
				sec = "朝"
			case(12...17):
				sec = "お昼"
			case(18...23):
				sec = "夜"
			case(0...5):
				sec = "深夜"
			default:
				break
		}
		
		return sec
	}
	
	func clearNoUseChars(text: String) -> String {
		var ptn = "（.+）"
		var afterText = text.stringByReplacingOccurrencesOfString(
			ptn, withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		
		ptn = "(\\r\\n)+[\\s　]+"
		afterText = afterText.stringByReplacingOccurrencesOfString(
			ptn, withString: "\r\n", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		
		return afterText
	}
	
	func loadTextFile() -> String {
		let data = resToData(TEXT_FILE_NAME)
		
		return dataToStr(data!)!
	}
	
	func loadTextFileAndSplit() {
		let allText = loadTextFile()
		var texts = allText.componentsSeparatedByString("【")
		texts.removeFirst()
		
		for text in texts {
			// セクション名切り出し
			getSectionName(text)
			
			var words = text.componentsSeparatedByString("「")
			words.removeFirst()
			_allVoiceWords[_sectionName] = [String]()
			
			for var word in words {
				word = word.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
				word = clearNoUseChars(word)
				var ws = word.componentsSeparatedByString("」")
				_allVoiceWords[_sectionName]?.append(ws[0])
			}
		}
	}
	
	func getSectionName(text: String) {
		let ptn = "([^【】\\s]+)"
		let r = Regexp(ptn).matches(text)! as [String]
		_sectionName = r[0]
		/*
		let res = text.rangeOfString("】")
		
		if res != nil {
			let r = Regexp(ptn).matches(text)! as [String]
			_sectionName = r[0]
		}*/
		print(_sectionName)
	}
	
	// テキストファイル読み込み
	func loadTextFileAndSplitLines() {
		let data = resToData(TEXT_FILE_NAME)
		
		let text = dataToStr(data!)
		
		text!.enumerateLines { (line, stop) -> () in
			self.lineToWordsArray(line)
		}
		
		//print(_voiceWords)
		
		//for (key, words) in _voiceWords.enumerate() {
		//}
	}
	
	func lineToWordsArray(line: String) {
		let ptn = "([^【】\\s]+)"
		let res = line.rangeOfString("【")
		
		if res != nil {
			let r = Regexp(ptn).matches(line)! as [String]
			_sectionName = r[0]
			_allVoiceWords[_sectionName] = [String]()
		} else {
			// 空白削除
			let text = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			
			if !_sectionName.isEmpty && !text.isEmpty {
				_allVoiceWords[_sectionName]?.append(text)
			}
		}
	}
	
	func resToData(fileName: String) -> NSData? {
		let file = NSBundle.mainBundle().pathForResource(fileName, ofType: "")
		
		if file == nil {
			print("ERROR! ファイルが読み込めません")
			
			return nil
		}
		
		return NSData(contentsOfFile: file!)
	}
	
	func dataToStr(data: NSData) -> String? {
		return NSString(data: data, encoding: ENCODING) as? String
	}
}
