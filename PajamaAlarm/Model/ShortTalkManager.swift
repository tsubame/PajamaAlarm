//
//  ShortTalkManager.swift
//
//  Created by hideki on 2015/11/16.
//
//  ひとことメッセージ、挨拶を管理するクラス。
//  Resources/text 内にある台本データを読み込んで VoiceData 形式のデータを返す。
//
//  （依存クラス）
//	  ・Constants.swift
//	  ・Functions.swift
//	  ・VoiceFileManager.swift
//
//  （使い方）
//		let sm = ShortTalkManager()
//		let g  = sm.getGreetingVoiceData()
//		let v  = sm.getTalkVoiceData()
//		
//		print(g.text)
//		print(v.fileName)
//

import UIKit

class ShortTalkManager {

	// 定数
	let SHORT_TALK_TEXT_FILE_NAME = "ひとこと"	// ひとことデータのファイル名
	let GREETING_TEXT_FILE_NAME   = "挨拶"		// 挨拶データのファイル名
	let SHORT_TALK_ETC_SECTION    = "その他"		// ひとことデータで常に取得するセクション名
	
	// プライベート変数
	var _stVoices   = [String: [VoiceData]]()	// ひとことデータの配列
	var _gVoices    = [String: [VoiceData]]()	// 挨拶データの配列
	var _talkIndex  = 0							// ひとことデータのインデックス
	var _timePeriod = ""						// 時間帯
	
	
	// 初期化
	init() {
		loadVoiceDataFromFile()
	}
	
	//======================================================
	// ひとことデータ
	//======================================================
	
	// ひとことデータを1つ返す
	func getShortTalkData(date: NSDate? = nil) -> VoiceData? {
		// 時間帯、インデックスを設定
		setTimePeriodAndTalkIndex(date)
		
		// 現在の時間帯、【その他】の音声データを取得
		var datas = getShortTalkDatasForPeriod() + _stVoices[SHORT_TALK_ETC_SECTION]!
		if datas.count == 0 {
			return nil
		}
		
		if datas.count <= _talkIndex {
			_talkIndex = 0
		}
		
		return datas[_talkIndex++]
	}
	
	// 現在の時間帯のひとことデータを配列で返す
	func getShortTalkDatasForPeriod() -> [VoiceData] {
		if _stVoices[_timePeriod] == nil || _stVoices[SHORT_TALK_ETC_SECTION] == nil {
			print(ERROR_MSG + "ひとことファイルの書式エラーです")
			return [VoiceData]()
		}

		return _stVoices[_timePeriod]!
	}
	
	//======================================================
	// 挨拶データ
	//======================================================
	
	// 挨拶データを返す
	func getGreetingData(date: NSDate? = nil) -> VoiceData? {
		_timePeriod = getCurrentTimePeriod(date)
		if _gVoices[_timePeriod] == nil {
			print("挨拶ファイルの書式エラーです。\(_timePeriod)の項目がありません")
			return nil
		}
		
		let vDatas = _gVoices[_timePeriod]!
		var vData  = VoiceData()
		
		// ランダムで一つの挨拶データを返す
		while true {
			vData = vDatas[rand(vDatas.count)]
			
			// 他の呼び名が含まれていれば取得し直す
			if hasTextOtherNickname(vData.text) == false {
				break
			}
		}
	
		return vData
	}
	
	//======================================================
	// その他
	//======================================================
	
	// 台本からデータを読み込む
	func loadVoiceDataFromFile() {
		let vfm   = VoiceFileManager()
		_stVoices = vfm.loadDatasFromVoiceTextFile(SHORT_TALK_TEXT_FILE_NAME)
		_gVoices  = vfm.loadDatasFromVoiceTextFile(GREETING_TEXT_FILE_NAME)
	}
	
	// 現在の呼び名以外を含んでいるか
	func hasTextOtherNickname(text: String) -> Bool {
		let currentNickname = NSUserDefaults.standardUserDefaults().objectForKey(PREF_KEY_NICKNAME) as? String
		
		for nickname in NICKNAMES {
			if nickname == currentNickname {
				continue
			}
			if text.containsString(nickname) {
				return true
			}
		}
		
		return false
	}
	
	// 現在の時間帯とひとことデータのインデックスを返す
	func setTimePeriodAndTalkIndex(date: NSDate? = nil) {
		let ctp = getCurrentTimePeriod(date)
		if ctp != _timePeriod {
			_timePeriod = ctp
			_talkIndex  = 0
		}
	}
	
	// 現在の時間帯を返す　早朝、朝、昼、夜、深夜
	func getCurrentTimePeriod(date: NSDate? = nil) -> String {
		// バグが有るため未使用 let TIME_ZONE_NAMES = ["早朝": 4...5, "朝": 6...11, "昼": 12...17, "お昼": 12...17, "夜": 18...23, "深夜": 0...3]
		let defaultPeriod = "昼"
		
		var tZones		= ["早朝": 4...5]
		tZones["朝"]		= 6...11
		tZones["昼"]		= 12...17
		tZones["夜"]		= 18...23
		tZones["深夜"]	= 0...3
		
		var comps = CALENDAR.components([NSCalendarUnit.Hour], fromDate: NSDate())
		if date != nil {
			comps = CALENDAR.components([NSCalendarUnit.Hour], fromDate: date!)
		}
		
		for (time, timeRange) in tZones {
			for h in timeRange {
				if h == comps.hour {
					return time
				}
			}
		}
		
		return defaultPeriod
	}

}
