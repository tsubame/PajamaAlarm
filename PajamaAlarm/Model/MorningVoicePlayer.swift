//
//  MorningVoicePlayer.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/24.
//
//  （依存クラス）
//		Constants.swift, Functions.swift, VoiceFileManager.swift
//
//  （使い方）
//		let sm = ShortTalkManager()
//		let g  = sm.getGreetingVoiceData()
//		print(g.text)
//
//		let v = sm.getTalkVoiceData()
//		print(v.fileName)

import UIKit

class MorningVoicePlayer {

	// 定数
	let VOICE_TEXT_FILE_NAME = "おはようボイス"
	let WEATHER_SECTION_NAME = "お天気"
	let WEATHER_FILE_NUMBERS = [ 1: "晴れ", 2: "曇り", 3: "雨", 4: "豪雨"]
	
	// プライベート変数
	var _voiceDatas: [String: [VoiceData]]!
	var _voiceFileManager  = VoiceFileManager()
	var _sectionNames      = [String]()
	
	
	init() {
		loadVoiceData()
	}
	
	//
	func getMorningVoiceDatas(weather: String? = nil) -> [VoiceData] {
		var voices = [VoiceData]()
		voices.append(getHeadVoiceData())
		
		if weather != nil {
			voices += getWeatherVoiceDatas(weather!)
		}

		return voices
	}
	
	// 先頭に入る音声データを取得
	func getHeadVoiceData() -> VoiceData {
		// セクション名をランダムで取得
		let sec = getRandomlyFromArray(_sectionNames) as! String
		// セクション内のデータをランダムで取得
		let n     = rand(_voiceDatas[sec]!.count)
		let voice = _voiceDatas[sec]![n]

		if isOtherNicknameIn(voice.text) {
			return getHeadVoiceData()
		}
		
		return voice
	}
	
	//
	func getWeatherVoiceDatas(weather: String) -> [VoiceData] {
		var voices = [VoiceData]()
		
		let vData = getWeatherVoiceData(weather)
		if vData == nil {
			return voices
		}
		
		voices.append(_voiceDatas[WEATHER_SECTION_NAME]![0])
		voices.append(vData!)
		
		return voices
	}
	
	//
	func getWeatherVoiceData(weather: String) -> VoiceData? {
		for (n, w) in WEATHER_FILE_NUMBERS {
			if weather == w {
				return  _voiceDatas[WEATHER_SECTION_NAME]![n]
			}
		}
		
		return nil
	}
	
	func loadVoiceData() {
		_voiceDatas = _voiceFileManager.loadVoiceDatasFromFile(VOICE_TEXT_FILE_NAME)

		for (key, _) in _voiceDatas {
			if key == WEATHER_SECTION_NAME {
				continue
			}
			
			_sectionNames.append(key)
		}
	}
	
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
	
	func getRandomlyFromArray(array: NSArray) -> NSObject {
		let n = rand(array.count)

		return array[n] as! NSObject
	}
}
