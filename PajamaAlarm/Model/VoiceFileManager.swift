//
//  VoiceFileManager.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/23.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//
//　（説明）
//　・台本データの原文をフォーマットし、音声ファイルリスト（フォーマットした台本データ）を作成。
//　・音声ファイルリストを読み込んで VoiceDataの連想配列を返す
//

import UIKit

//
struct VoiceData {
	var text     = ""
	var fileName = ""
	var face     = ""
}

class VoiceFileManager {
 
	// 定数
	let VOICE_TEXT_FILE_NAMES   = ["挨拶", "ひとこと", "おはようボイス"]		// 台本、音声リストのファイル名（拡張子なし）
	let VOICE_TEXT_FILE_SUFFIX  = ".txt"								// 台本、音声リストの拡張子
	let VOICE_TEXT_SEC_HEAD     = "【"									// 台本のセクションの先頭
	let VOICE_TEXT_SPLIT_CHAR	= "／"									// 台本のセリフの区切り
	let VOICE_LIST_DIR_PATH     = PATH_TO_DOCUMENTS as NSString			// 音声リストのディレクトリ
	let VOICE_LIST_LINE_HEAD	= "・"									// 音声リストの行の先頭
	let VOICE_LIST_FILE_SUFFIX  = "_音声ファイルリスト.txt"					// 音声リストのファイルの接尾辞
	let VOICE_SOUND_FILE_SUFFIX = ".mp3"								// 音声ファイルの拡張子
	let REG_PTN_FACE_EX			= "<(.+)>"								// 表情パターンの文字列の正規表現
	let CRLF                    = "\r\n"								// 改行コード

	
	// 初期化
	init() {
		checkVoiceTextFileExists()
		outputVoiceListFiles()
	}
	
	
	//======================================================
	// 台本の読み込み
	//======================================================
	
	// 台本ファイルを読み込んで、VoiceDataの連想配列を返す
	func loadVoiceTextFile(fileName: String) -> [String: [VoiceData]] {
		var voices = [String: [VoiceData]]()
		
		// テキストファイルを読み込み、"【" で区切る
		let text     = loadTextFromFile(fileName)
		let secTexts = splitToSection(text)
		
		for secText in secTexts {
			// セクション名の取得
			let secName     = getSecNameFromStr(secText)
			voices[secName] = [VoiceData]()
			
			// セリフを配列で取得
			let voiceTexts = getVoiceTextsFromStr(secText)
			// VoiceDataに変換し、連想配列に追加
			for (i, vText) in voiceTexts.enumerate() {
				voices[secName]! += makeVoiceDatas(vText, fileName: fileName, secName: secName, index: i)
			}
		}
		
		return voices
	}
	
	// 【 】がある箇所で分割し配列にして返す
	func splitToSection(text: String) -> [String] {
		var texts = text.componentsSeparatedByString(VOICE_TEXT_SEC_HEAD)
		texts.removeFirst()
		
		return texts
	}
	
	// 台本ファイルの各セリフから、構造体 VoiceData() の配列を生成
	func makeVoiceDatas(vText: String, fileName: String, secName: String, index: Int) -> [VoiceData] {
		var voice      = VoiceData()
		voice.fileName = createVoiceFileName(fileName, prefix1: secName, index: index)
		voice.text     = vText
		let voices	   = splitVoices(voice)
		
		return voices
	}
	
	//======================================================
	// 音声リストの読み込み
	//======================================================
	
	func loadVoiceListToDict(fileName: String) -> [String: [[VoiceData]]] {
		var dict = [String: [[VoiceData]]]()
		
		// テキストファイルを読み込み、"【" で区切る
		let texts = getSectionTextsFromVoiceListFile(fileName)

		for text in texts {
			let secName   = getSecNameFromStr(text)
			dict[secName] = [[VoiceData]]()
			
			// 各行を配列で取得
			let blocks = getVoiceListsFromText(text)
			for block in blocks {
				var voices = [VoiceData]()
				let lines = block.componentsSeparatedByString(VOICE_LIST_LINE_HEAD)
				
				for line in lines {
					let voice = makeVoiceDataFromVoiceListLine(line)
					voices.append(voice)
				}
				
				dict[secName]?.append(voices)
			}
		}
		
		return dict
	}
	
	// 音声ファイルリストを読み込み、【 】がある箇所で分割し配列にして返す
	func getSectionTextsFromVoiceListFile(fileName: String) -> [String] {
		var texts = [String]()
		
		do {
			let path = VOICE_LIST_DIR_PATH.stringByAppendingPathComponent(fileName + VOICE_LIST_FILE_SUFFIX)
			let text = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
			if text.isEmpty {
				return texts
			}
			
			texts = text.componentsSeparatedByString(VOICE_TEXT_SEC_HEAD)
			texts.removeFirst()
		} catch {
			print(ERROR_MSG + "音声ファイルリストの読み込みエラーです。\(fileName)")
		}
		
		return texts
	}
	
	// VoiceDataを音声ファイルリストの行から取得
	func makeVoiceDataFromVoiceListLine(line: String) -> VoiceData {
		var voice      = VoiceData()
		voice.fileName = searchWithRegex(line, ptn: "^.+" + VOICE_SOUND_FILE_SUFFIX)
		voice.text     = searchWithRegex(line, ptn: "「(.+)」", rangeAtIndex: 1) //searchWithRegex(line, ptn: "「.+」")
		voice.text     = replaceSpaceToCRLF(voice.text)
		voice.face     = searchWithRegex(line, ptn: "<(.+)>", rangeAtIndex: 1)
		
		return voice
	}
	
	// 音声ファイルリストの行のみを返す　連番の行は複数行で返す
	func getVoiceListsFromText(text: String) -> [String] {
		var vTexts = [String]()
		
		var texts = text.componentsSeparatedByString(CRLF + CRLF + VOICE_LIST_LINE_HEAD)
		texts.removeFirst()

		// 改行を削除
		for str in texts {
			let res = str.componentsSeparatedByString(CRLF + CRLF)
			vTexts.append(res[0])
		}
		
		return vTexts
	}
	
	//======================================================
	// 音声リストの出力
	//======================================================
	
	// 全ての台本から音声リストファイルを作成
	func outputVoiceListFiles() -> Bool {
		
		for fileName in VOICE_TEXT_FILE_NAMES {
			var output = ""
			// 台本読み込み
			let dict = loadVoiceTextFile(fileName)
			
			for (sec, datas) in dict {
				output += "\(CRLF)【 \(sec) 】\(CRLF)"
				
				for v in datas {
					output += createVoiceListLine(v)
				}
				output += "\(CRLF)\(CRLF)\(CRLF)"
			}
			
			// ファイルを出力
			if writeVoiceListFile(output, fileName: fileName) == false {
				return false
			}
		}
		
		return true
	}
	
	// 音声データを音声リストの1行分のテキストに変換
	func createVoiceListLine(vData: VoiceData) -> String {
		let fileNameStrCount = 20
		
		var text = ""
		if !isSplitedVoice(vData) {
			text += "\(CRLF)"
		}
		
		let fileNameStr = vData.fileName.stringByPaddingToLength(fileNameStrCount, withString: " ", startingAtIndex: 0)
		text += "\(CRLF)・\(fileNameStr)「\(replaceCRLFtoSpace(vData.text))」"
		
		if !vData.face.isEmpty {
			text += " <\(vData.face)>"
		}
		
		return text
	}
	
	// 1件の音声リストファイルを出力
	func writeVoiceListFile(text: String, fileName: String) -> Bool {
		let path = VOICE_LIST_DIR_PATH.stringByAppendingPathComponent(fileName + VOICE_LIST_FILE_SUFFIX)
		
		let data = text.dataUsingEncoding(NSUTF8StringEncoding)
		if data == nil {
			return false
		}
		
		let res = data!.writeToFile(path, atomically: true)
		if res == true {
			print("\(path)に書き込みました。")
		}
		
		return res
	}

	
	//======================================================
	// テキスト処理
	//======================================================
	
	// セリフを2つに分割 ／ で句切られる
	func splitVoices(orgVoice: VoiceData) -> [VoiceData] {
		var voices = [VoiceData]()
		
		let texts = orgVoice.text.componentsSeparatedByString(VOICE_TEXT_SPLIT_CHAR)
		
		for (i, text) in texts.enumerate() {
			var v      = VoiceData()
			v.text     = text
			v.fileName = orgVoice.fileName
			
			// ファイル名の決定
			if 1 < texts.count {
				v.fileName += "_" + String(i) + VOICE_SOUND_FILE_SUFFIX
			} else {
				v.fileName += VOICE_SOUND_FILE_SUFFIX
			}
			
			v.text = cutHeadSpace(v.text)
			v      = setFacialEx(v)
			
			voices.append(v)
		}
		
		return voices
	}
	
	// 改行をスペースに変換
	func replaceCRLFtoSpace(text: String) -> String {
		let vText = text.stringByReplacingOccurrencesOfString("\r\n", withString: "　", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		
		return vText
	}
	
	// 全角スペースを改行に変換
	func replaceSpaceToCRLF(text: String) -> String {
		let vText = text.stringByReplacingOccurrencesOfString("　", withString: "\r\n", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		
		return vText
	}
	
	// テキストの中から表情パターンを取り出し、.face にセット。 <笑>のような形で入っている
	func setFacialEx(var vData: VoiceData) -> VoiceData {
		let nsText = vData.text as NSString
		
		// 検索
		let reg = try? NSRegularExpression(pattern: REG_PTN_FACE_EX, options: NSRegularExpressionOptions())
		let res = reg?.firstMatchInString(vData.text, options: NSMatchingOptions(), range: NSMakeRange(0, nsText.length))
		
		// 取り出し、置き換え
		if res != nil {
			vData.face = nsText.substringWithRange((res?.rangeAtIndex(1))!)
			vData.text = vData.text.stringByReplacingOccurrencesOfString(REG_PTN_FACE_EX, withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		}
		
		return vData
	}

	
	// 音声ファイル名を作成
	func createVoiceFileName(prefix0: String, prefix1: String, index: Int, prefix2: String? = nil) -> String {
		var fileName = prefix0 + "_" + prefix1
		
		if prefix2 != nil {
			fileName += "_" + prefix2!
		}
		
		fileName += "_" + String(index) //+ VOICE_SOUND_FILE_SUFFIX
		
		return fileName
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
	
	// 先頭の空白、改行を削除
	func cutHeadSpace(text: String) -> String {
		let vText        = text.stringByReplacingOccurrencesOfString("^\r\n", withString: "　", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
		let deleteTarget = NSCharacterSet.whitespaceCharacterSet
		let after        = vText.stringByTrimmingCharactersInSet(deleteTarget())

		return after
	}
	
	// 分割されたセリフかを判別
	func isSplitedVoice(vData: VoiceData) -> Bool {
		let fileName = vData.fileName as NSString
		
		// 検索
		let reg = try? NSRegularExpression(pattern: "\\d_[1-9]\\.", options: NSRegularExpressionOptions())
		let res = reg?.firstMatchInString(fileName as String, options: NSMatchingOptions(), range: NSMakeRange(0, fileName.length))
		
		// 取り出し、置き換え
		if res != nil {
			return true
		}
		
		return false
	}
	
	//======================================================
	// ファイルの存在確認
	//======================================================
	
	// 全てのファイルの存在確認
	func checkAllFileExists() {
		checkVoiceTextFileExists()
		
		for fileName in VOICE_TEXT_FILE_NAMES {
			let vDatas = loadVoiceTextFile(fileName)
			checkSoundFileExists(vDatas)
		}
	}
	
	// テキストファイルの存在確認
	func checkVoiceTextFileExists() -> Bool {
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
	
	
	
	
	
	
	
	
//
	func outputFormatFiles() -> Bool {
		for fileName in VOICE_TEXT_FILE_NAMES {
			let voiceDatas = loadVoiceTextFile(fileName)
			var text       = ""
			
			for (sec, vDatas) in voiceDatas {
				text += "\(CRLF)【 \(sec) 】\(CRLF)"
				
				for vData in vDatas {
					text += createVoiceListLine(vData)
				}
				text += "\(CRLF)\(CRLF)\(CRLF)"
			}
			
			let res = writeVoiceListFile(text, fileName: fileName)
			if res == false {
				return false
			}
		}
		
		return true
	}
	//======================================================
	// 出力
	//======================================================
	
	// 元の台本ファイルを加工して別ファイルに出力　セリフの上にファイル名を付加する
	func outputNewFiles() -> Bool {
		var success = true
		
		for fileName in VOICE_TEXT_FILE_NAMES {
			let voiceDatas = loadVoiceTextFile(fileName)
			var text = ""
			
			for (secName, vDatas) in voiceDatas {
				text += "\n【 " + secName +  " 】\n\n"
				
				for vData in vDatas {
					text += "・\(vData.fileName)　　"
					let ptn = "\r\n"
					let vText = vData.text.stringByReplacingOccurrencesOfString(ptn, withString: "　", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
					text += "　「\(vText)」\n\n"
				}
			}
			
			let path = VOICE_LIST_DIR_PATH.stringByAppendingPathComponent(fileName + "_音声ファイルリスト" + ".txt")
			let data = text.dataUsingEncoding(NSUTF8StringEncoding)
			let res  = data?.writeToFile(path, atomically: true)
			
			if res == true {
				print("\(path)に書き込みました。")
			} else {
				success = false
			}
		}
		
		return success
	}

	
	
}
