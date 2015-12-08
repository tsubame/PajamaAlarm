//
//  MorningVoiceManager.swift
//
//  Created by hideki on 2015/11/24.
//
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

class MorningVoiceManager {
	
	// 定数
	let VOICE_TEXT_FILE_NAME = "おはようボイス"								// 台本データのファイル名
	let WEATHER_SECTION_NAME = "お天気"										// お天気セクションの名前
	let WEATHER_FILE_NUMBERS = [ 1: "晴れ", 2: "曇り", 3: "雨", 4: "豪雨"]		// お天気セクション内の番号

	// プライベート変数
	var _voiceDatas: [String: [VoiceData]]!
	var _voiceFileManager = VoiceFileManager()
	var _sectionNames     = [String]()
	
	
	// 初期化
	init() {
		loadVoiceDataFromFile()
	}
	
	
	
	// おはようボイス用の一連の音声データを返す。天気を指定すると天気関連のデータをくっつけて返す
	func getMorningVoiceDatas(weather: String? = nil) -> [VoiceData] {
		var voices = [VoiceData]()
		voices.append(getHeadData())
		
		// お天気データをくっつける
		if weather != nil {
			voices += getWeatherDatas(weather!)
		}
		
		return voices
	}
	
	//======================================================
	// ファイルからの読み込み
	//======================================================m
	
	// 音声データをファイルから読み込む
	func loadVoiceDataFromFile() {
		_voiceDatas = _voiceFileManager.loadDatasFromVoiceTextFile(VOICE_TEXT_FILE_NAME)
		
		for (key, _) in _voiceDatas {
			if key == WEATHER_SECTION_NAME {
				continue
			}
			
			_sectionNames.append(key)
		}
	}
	
	//======================================================
	// その他
	//======================================================
	
	// 先頭に入る音声データを返す
	func getHeadData() -> VoiceData {
		// セクション名をランダムで取得
		let sec = getRandomlyFromArray(_sectionNames) as! String
		// セクション内のデータをランダムで取得
		let n     = rand(_voiceDatas[sec]!.count)
		let voice = _voiceDatas[sec]![n]
		
		// 現在の呼び名以外が入っていれば取得し直す
		if isOtherNicknameIn(voice.text) {
			return getHeadData()
		}
		
		return voice
	}
	
	// お天気関連のデータを配列で返す
	func getWeatherDatas(weather: String) -> [VoiceData] {
		var voices = [VoiceData]()
		
		let vData = getWeatherData(weather)
		if vData == nil {
			return voices
		}
		
		voices.append(_voiceDatas[WEATHER_SECTION_NAME]![0])
		voices.append(vData!)
		
		return voices
	}
	
	// 指定された天気に関連するデータを返す
	func getWeatherData(weather: String) -> VoiceData? {
		for (n, w) in WEATHER_FILE_NUMBERS {
			if weather == w {
				return  _voiceDatas[WEATHER_SECTION_NAME]![n]
			}
		}
		
		return nil
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

}
