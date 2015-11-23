//
//  GreetingManager
//  PajamaAlarm
//
//  Created by hideki on 2015/11/23.
//
//  挨拶メッセージを管理するクラス。
//  greeting.txt から挨拶データを取得し、時間帯、呼び名に合った挨拶データ（テキスト、ファイル名）を返す。
//
//  （依存クラス）
//		Constants.swift, Functions.swift
//
//  （使い方）
//		var gm = GreetingManager()
//		var gr = gm.getRandomGreeting()
//		print(gr.text)
//		print(gr.fileName)
//

import UIKit

// 挨拶データ保存用の構造体
struct Greeting {

	var text     :String! // テキスト
	var fileName :String! // ファイル名
	
	init () {
		text     = ""
		fileName = ""
	}
}



class GreetingManager: NSObject {
	
	// 定数
	let GREETING_FILE_NAME = "greeting.txt" // デフォルトの挨拶ファイル名
	let VOICE_FILE_SUFFIX  = ".mp3"
	let FILE_SEP_CHAR      = "【"			// ファイルの区切り文字
	
	// プロパティ
	var errorMessage: String = ""	// エラーメッセージ
	
	// プライベート変数
	var _textFileName : String!		// 挨拶ファイル名
	var _nickname     : String?		// ほたるからの呼び名
	var _greetingTexts = [String: [String]]()
	
	var _allGreetings  = [String: [[String: String]]]()
	
	
	override init() {
		super.init()
		
		_textFileName = GREETING_FILE_NAME
		_nickname     = NSUserDefaults.standardUserDefaults().objectForKey(PREF_KEY_NICKNAME) as? String
		
		loadGreetingTexts()
		checkAllFileExists()
	}
	
	// 挨拶をランダムで返す
	func getRandomGreeting() -> Greeting? {
		let time = getTimezoneOfNow()
		if _greetingTexts[time]!.isEmpty {
			return nil
		}
		
		let timeGreetings = _greetingTexts[time]
		var greetings     = [Greeting?]()
		
		// 現在の呼び名以外が含まれる挨拶をカット
		for (i, text) in (timeGreetings?.enumerate())! {
			if isExistsOtherNicknameInText(text) {
				continue
			}
			
			var gr      = Greeting()
			gr.text     = text
			gr.fileName = "\(time)\(i)\(VOICE_FILE_SUFFIX)"
			greetings.append(gr)
		}
		
		return greetings[rand(greetings.count)]
	}
	
	//======================================================
	// ファイル処理
	//======================================================
	
	// 挨拶データをファイルから読み込む
	func loadGreetingTexts() {
		let text = loadTextFromFile(_textFileName)
		if text.isEmpty {
			errorMessage += ERROR_MSG + "\(_textFileName) ファイルが読み込めません \n"
			return
		}
		
		// "【" の箇所で分割
		var sTexts = text.componentsSeparatedByString(FILE_SEP_CHAR)
		sTexts.removeFirst()
		
		// セリフを連想配列へ
		for sText in sTexts {
			let time   = getTimezoneFromText(sText)
			let vWords = getVoiceWordsFromText(sText)
			
			if !time.isEmpty {
				_greetingTexts[time] = vWords
			}
		}
	}
	
	// 音声ファイルの存在確認
	func checkAllFileExists() {
		for (time, greetings) in _greetingTexts {
			for (i, text) in greetings.enumerate() {
				let fileName = getFileNameOfGreeting(time, index: i)
				
				if isFileExists(fileName) == false {
					errorMessage += ERROR_MSG + "音声ファイルがありません！: " + fileName + " " + text + "\n"
				}
			}
		}
	}
	
	// 挨拶データのファイル名を返す　時間帯、番号から変換
	func getFileNameOfGreeting(timezone: String, index: Int) -> String {
		let fileName = "\(timezone)\(index)\(VOICE_FILE_SUFFIX)"
		
		return fileName
	}
	
	// 挨拶ファイルを読み込み、【 】がある行で分割し配列に
	func loadTextFileAndSplit() {
		let fullText = loadTextFromFile(_textFileName)
		if fullText.isEmpty {
			return
		}
		
		var secTexts = fullText.componentsSeparatedByString("【")
		secTexts.removeFirst()
		
		for text in secTexts {
			let time       = getTimezoneFromText(text)
			let voiceWords = getVoiceWordsFromText(text)
			if time.isEmpty {
				continue
			}
			
			_greetingTexts[time] = voiceWords
		}
	}
	
	// テキストからセリフ（かぎかっこ内のテキスト）だけを取り出し、配列で返す。（例）"「こんにちは」「ありがとう」" →  ["こんにちは", "ありがとう"]
	func getVoiceWordsFromText(text: String) -> [String] {
		var voiceWords = [String]()
		
		var strs = text.componentsSeparatedByString("「")
		strs.removeFirst()
		
		// 空白、"」"以降を除去
		for var vWord in strs {
			vWord = vWord.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			let strs2 = vWord.componentsSeparatedByString("」")
			
			voiceWords.append(strs2[0])
		}
		
		return voiceWords
	}
	
	// 【 】 内の文字列を返す。空白は除く。
	func getTimezoneFromText(text: String) -> String {
		let nsText = text as NSString
		let ptn    = "([^【\\s　]+)[\\s　]*】"
		
		let regex  = try? NSRegularExpression(pattern: ptn, options: NSRegularExpressionOptions())
		let result = regex?.firstMatchInString(text, options: NSMatchingOptions(), range: NSMakeRange(0, nsText.length))
		
		if result != nil {
			return nsText.substringWithRange((result?.rangeAtIndex(1))!)
		}
		
		return ""
	}
	
	// 現在の呼び名以外がテキストに含まれるか
	func isExistsOtherNicknameInText(text: String) -> Bool {
		if _nickname == nil {
			return false
		}
		
		for nName in NICKNAMES {
			if (text.rangeOfString(nName) != nil) {
				if nName != _nickname {
					return true
				}
			}
		}
		
		return false
	}
	
	
	
	// 挨拶メッセージとファイル名を出力。デバッグ用
	func printFileNamesAndTexts() {
		loadTextFileAndSplit()
		
		for (key, greetings) in _greetingTexts {
			print(greetings)
			
			for (i, text) in greetings.enumerate() {
				let fileName = "\(key)\(i).m4a"
				print(text)
				print(fileName)
			}
		}
	}
	
	// 挨拶データをテキストファイルから _allGreetings に取得
	func loadGreetingsFromFile() {
		let fullText = loadTextFromFile(_textFileName)
		if fullText.isEmpty {
			return
		}
		
		// "【" で分割
		var sTexts = fullText.componentsSeparatedByString("【")
		sTexts.removeFirst()
		
		for text in sTexts {
			// 時間帯を取得
			let time = getTimezoneFromText(text)
			if time.isEmpty {
				continue
			}
			
			// セリフを配列で取り出す
			let vWords    = getVoiceWordsFromText(text)
			for (i, vWord) in vWords.enumerate() {
				var g      = [String: String]()
				g["text"]  = vWord
				g["fileName"] = getFileNameOfGreeting(vWord, index: i)
				
				_allGreetings[time]![i] = g
			}
		}
	}
}
