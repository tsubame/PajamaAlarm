//
//  MorningVoiceBuilder.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/12/05.
//
//	（説明）
//		おはようボイスを管理するクラス。
//		Resources/text/内の台本データを読み込み、時間帯別にランダムでボイスデータを返す。
//
//  （依存ファイル）
//		Constants.swift
//		Functions.swift
//		VoiceFileManager.swift
//		VoiceUtil.swift
//
//  （使い方）
//		let m = MorningVoiceManager()
//		let vDatas: [VoiceData] = m.getMorningVoiceDatas("晴れ")
//		print(vDatas.text)
//

import UIKit

class MorningVoiceBuilder {
	
	// 定数
	let VOICE_TEXT_FILE_NAME = "おはようボイス"								// 台本データのファイル名
	let WEATHER_SECTION_NAME = "お天気"										// お天気セクションの名前
	let WEATHER_FILE_NUMBERS = [ 1: "晴れ", 2: "曇り", 3: "雨", 4: "豪雨"]		// お天気セクション内の番号
	
	// プライベート変数
//var _voiceDatas: [String: [VoiceData]]!

	var _voiceDict: [String: [[VoiceData]]]!
	var _voiceFileManager = VoiceFileManager()
	var _sectionNames     = [String]()
	var _voiceUtil		  = VoiceUtil()
	
	
	// 初期化
	init() {
		loadVoiceDataFromFile()
	}
	
	// 処理実行
	func exec(weather: String? = nil) -> [VoiceData] {
		return getMorningVoiceDatas(weather)
	}
	
	//======================================================
	// ファイルからの読み込み
	//======================================================m
	
	// 音声データをファイルから読み込む
	func loadVoiceDataFromFile() {		
		//_voiceDatas = _voiceFileManager.loadDatasFromVoiceListFile(VOICE_TEXT_FILE_NAME)
		_voiceDict  = _voiceFileManager.loadVoiceListToDict(VOICE_TEXT_FILE_NAME)
		
		for (key, _) in _voiceDict {
			if key == WEATHER_SECTION_NAME {
				continue
			}
			
			_sectionNames.append(key)
		}
	}
	
	//======================================================
	// その他
	//======================================================
	
	// おはようボイス用の一連の音声データを返す。天気を指定すると天気関連のデータをくっつけて返す
	func getMorningVoiceDatas(weather: String? = nil) -> [VoiceData] {
		var voices = [VoiceData]()
		voices = getHeadDatas()
		//voices.append(getHeadData())
		
		// お天気データをくっつける
		if weather != nil {
			voices += getWeatherDatas(weather!)
// 気温データの表示テスト 
			voices.append(getTempSample())
		}
		
		return voices
	}
	
	// 先頭に入る音声データを返す
	func getHeadDatas() -> [VoiceData] {
		var voices = [VoiceData]()
		// セクション名をランダムで取得
		let sec = getRandomlyFromArray(_sectionNames) as! String
		// セクション内のデータをランダムで取得
		let n  = rand(_voiceDict[sec]!.count)
		voices = _voiceDict[sec]![n]

		// 現在の呼び名以外が入っていれば取得し直す
		if isOtherNicknameIn(voices[0].text) {
			voices = getHeadDatas()
		}
		
		return voices
	}

	// お天気関連のデータを配列で返す
	func getWeatherDatas(weather: String) -> [VoiceData] {
		var voices = [VoiceData]()
		
		let head  = _voiceDict[WEATHER_SECTION_NAME]![0][0]
		let tails = getWeatherTailVoices(weather)
		
		// 先頭のデータ
		voices.append(head)
		voices += tails
		
		return voices
	}
	
	// 指定された天気に関連するデータを返す
	func getWeatherTailVoices(weather: String) -> [VoiceData] {
		let voices = [VoiceData]()
		
		for (n, w) in WEATHER_FILE_NUMBERS {
			if weather == w {
				return _voiceDict[WEATHER_SECTION_NAME]![n]
			}
		}
		
		return voices
	}
	
	// 他の呼び名が入っているか
	func isOtherNicknameIn(text: String) -> Bool {
		let nickname = readPref(PREF_KEY_NICKNAME) as? String
		if nickname == nil {
			print(ERROR_MSG + "呼び名が設定されていません")
			return false
		}
		
		for otherName in NICKNAMES {
			if otherName == nickname {
				continue
			}
			if text.containsString(otherName) {
				return true
			}
		}
		
		return false
	}
	
	// 配列からランダムで一つのデータを返す
	func getRandomlyFromArray(array: NSArray) -> NSObject {
		let n = rand(array.count)
		
		return array[n] as! NSObject
	}
	


	//======================================================
	// サンプル
	//======================================================

	// 気温データの表示テスト
	func getTempSample() -> VoiceData {
		var text = ""
		
		let p = readPref(PREF_KEY_T_POP) as? Int
		if p != nil {
			if 0 < p! {
				text += "降水確率は\(p!)%。\n"
			}
		}
		let m = readPref(PREF_KEY_T_MIN_TEMP) as? Int
		if m != nil {
			text += "最低気温は\(m!)℃"
		}
		
		let y = readPref(PREF_KEY_Y_MIN_TEMP) as? Int
		if y != nil && m != nil{
			let def = m! - y!
			var defStr = "+\(def)"
			if def < 0 {
				defStr = "\(def)"
			}
			text += "昨日に比べて \(defStr)℃"
		}
		
		text += "だよ。"
		
		var voice = VoiceData()
		voice.text = text
		
		return voice
	}
	
	
	
	
	
	
	// 削除予定
	// 先頭に入る音声データを返す
	func getHeadData() -> VoiceData {
		/*
		// セクション名をランダムで取得
		let sec = getRandomlyFromArray(_sectionNames) as! String
		// セクション内のデータをランダムで取得
		let n     = rand(_voiceDatas[sec]!.count)
		let voice = _voiceDatas[sec]![n]
		
		// 現在の呼び名以外が入っていれば取得し直す
		if isOtherNicknameIn(voice.text) {
		return getHeadData()
		}*/
		let voice = VoiceData()
		
		return voice
	}
	
	
	
}
