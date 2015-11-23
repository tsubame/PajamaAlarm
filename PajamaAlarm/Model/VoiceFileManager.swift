//
//  VoiceFileManager.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/23.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit

//
struct VoiceData {
	var text     = ""
	var fileName = ""
	var face     = ""
}

class VoiceFileManager: NSObject {
 
	// 定数
	let VOICE_TEXT_FILE_NAMES   = ["挨拶", "ひとこと", "おはようボイス"]
	let VOICE_TEXT_FILE_SUFFIX  = ".txt"
	let VOICE_SOUND_FILE_SUFFIX = ".mp3"
	let VOICE_TEXT_SPLIT_CHAR   = "【"
	
	
	override init() {
		super.init()
	}
	
	//
	func checkAllFileExists() {
		checkTextFileExists()
		
		for fileName in VOICE_TEXT_FILE_NAMES {
			let vDatas = loadVoiceDatasFromFile(fileName)
			checkSoundFileExists(vDatas)
		}
	}
	
	// テキストファイルの存在確認
	func checkTextFileExists() -> Bool {
		var error = false
		
		for name in VOICE_TEXT_FILE_NAMES {
			let fileName = name + VOICE_TEXT_FILE_SUFFIX
			
			if isFileExists(fileName) == false {
				print("ファイルがありません！: " + fileName)
				error = true
			}
		}
		
		return error
	}
	
	// 音声ファイルの存在確認
	func checkSoundFileExists(voiceDatas: [String: [VoiceData]]) -> Bool {
		var error = false
		
		for (_, vDatas) in voiceDatas {
			for vData in vDatas {
				if isFileExists(vData.fileName) == false {
					print("ファイルがありません！: " + vData.fileName)
					error = true
				}
			}
		}
		
		return error
	}
	
	// 元の台本ファイルを加工して別ファイルに出力　セリフの上にファイル名を付加する
	func outputNewFiles() {
		for fileName in VOICE_TEXT_FILE_NAMES {
			let voiceDatas = loadVoiceDatasFromFile(fileName)
			var text = ""
			
			for (secName, vDatas) in voiceDatas {
				text += "\n【 " + secName +  " 】\n\n"
				for vData in vDatas {
					text += "(" + vData.fileName + ")\n"
					text += "「" + vData.text + "」\n\n"
				}
			}
			
			print(text)
		}
	}
	
	//
	func loadVoiceDatasFromFile(fileName: String) -> [String: [VoiceData]] {
		var vDatas = [String: [VoiceData]]()
		
		// テキストファイルを読み込み、"【" で区切る
		let texts = loadTextFileAndSplit(fileName)
		if texts == nil {
			return vDatas
		}
		
		for text in texts! {
			// セクション名、セリフを取り出す
			let sName     = getSecNameFromStr(text)
			let vTexts    = getVoiceTextsFromStr(text)
			vDatas[sName] = [VoiceData]()
			
			// 構造体の形で連想配列に追加
			for (i, vText) in vTexts.enumerate() {
				var vData      = VoiceData()
				vData.fileName = getVoiceFileName(fileName, prefix1: sName, prefix2: nil, index: i)
				vData.text     = vText
				
				vDatas[sName]?.append(vData)
			}
		}
		
		return vDatas
	}
	
	//
	func getVoiceFileName(prefix0: String, prefix1: String, prefix2: String?, index: Int) -> String {
		
		var fileName = prefix0 + "_" + prefix1
		
		if prefix2 != nil {
			fileName += "_" + prefix2!
		}
		
		fileName += "_" + String(index) + VOICE_SOUND_FILE_SUFFIX
		
		return fileName
	}
	
	// テキストファイルを読み込み、【 】がある箇所で分割し配列に
	func loadTextFileAndSplit(fileName: String) -> [String]? {
		let text = loadTextFromFile(fileName)
		if text.isEmpty {
			return nil
		}
		
		var texts = text.componentsSeparatedByString(VOICE_TEXT_SPLIT_CHAR)
		texts.removeFirst()
		
		return texts
	}
	
	// 【 】 内の文字列を返す。空白は除去。
	func getSecNameFromStr(text: String) -> String {
		let nsText = text as NSString
		let ptn    = "([^【\\s　]+)[\\s　]*】"
		
		let regex  = try? NSRegularExpression(pattern: ptn, options: NSRegularExpressionOptions())
		let result = regex?.firstMatchInString(text, options: NSMatchingOptions(), range: NSMakeRange(0, nsText.length))
		
		if result != nil {
			return nsText.substringWithRange((result?.rangeAtIndex(1))!)
		}
		
		return ""
	}
	
	// 「 」内のセリフを取り出し、配列で返す。（例）"「こんにちは」「ありがとう」" →  ["こんにちは", "ありがとう"]
	func getVoiceTextsFromStr(str: String) -> [String] {
		var vTexts = [String]()
		
		var strs = str.componentsSeparatedByString("「")
		strs.removeFirst()
		
		// 空白、"」"以降を除去
		for var v in strs {
			v = cutNoUseChars(v)
			let res = v.componentsSeparatedByString("」")
			
			vTexts.append(res[0])
		}
		
		return vTexts
	}
	
	// 不要な文字を削除　全角空白の連続
	func cutNoUseChars(text: String) -> String {
		let ptn = "（.+）"
		var afterText = text.stringByReplacingOccurrencesOfString(
			ptn, withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		
		let ptn2 = "(\\r\\n)+[\\s　]+"
		afterText = afterText.stringByReplacingOccurrencesOfString(
			ptn2, withString: "\r\n", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		
		// 半角空白を削除
		afterText = afterText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		return afterText
	}
}
