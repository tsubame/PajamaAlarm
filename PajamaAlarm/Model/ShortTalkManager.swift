//
//  ShortTalkManager.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/16.
//
//  ひとことメッセージ、挨拶を管理するクラス。
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

class ShortTalkManager: NSObject {

	// 定数
	let TALK_TEXT_FILE_NAME     = "ひとこと"
	let GREETING_TEXT_FILE_NAME = "挨拶"
	
	// プライベート変数
	var _talkVoiceDatas     = [String: [VoiceData]]()
	var _greetingVoiceDatas = [String: [VoiceData]]()
	
	var _talkIndex  = 0  // ひとことのインデックス
	var _timePeriod = "" // 時間帯
	var _voiceFileManager = VoiceFileManager()
	
	
	override init() {
		super.init()
		
		loadVoiceDatas()
	}
	
	//
	func loadVoiceDatas() {
		_talkVoiceDatas     = _voiceFileManager.loadVoiceDatasFromFile(TALK_TEXT_FILE_NAME)
		_greetingVoiceDatas = _voiceFileManager.loadVoiceDatasFromFile(GREETING_TEXT_FILE_NAME)
	}
	
	//
	func getTalkVoiceData(date: NSDate? = nil) -> VoiceData? {
		let ctp = getCurrentTimePeriod(date)
		if ctp != _timePeriod {
			_timePeriod = ctp
			_talkIndex  = 0
		}
		
		let voiceDatas = getTalkVoiceDatasForNow()
		if voiceDatas.count == 0 {
			return nil
		}
		
		if voiceDatas.count <= _talkIndex {
			_talkIndex = 0
		}
		let vd = voiceDatas[_talkIndex]
		_talkIndex++
		
		return vd
	}
	
	//
	func getTalkVoiceDatasForNow() -> [VoiceData] {
		if _talkVoiceDatas[_timePeriod] == nil || _talkVoiceDatas["その他"] == nil {
			print("ひとことファイルの書式エラーです")
			return [VoiceData]()
		}

		var voiceDatas = _talkVoiceDatas[_timePeriod]!
		voiceDatas = voiceDatas + _talkVoiceDatas["その他"]!
		
		return voiceDatas
	}
	
	func getGreetingVoiceData(date: NSDate? = nil) -> VoiceData? {
		_timePeriod = getCurrentTimePeriod(date)
		if _greetingVoiceDatas[_timePeriod] == nil {
			print("挨拶ファイルの書式エラーです。\(_timePeriod)の項目がありません")
			return nil
		}
		
		let vDatas = _greetingVoiceDatas[_timePeriod]!
		var vData  = VoiceData()
		
		while true {
			let n = rand(vDatas.count)
			vData = vDatas[n]
		
			if hasTextOtherNickname(vData.text) == false {
				break
			}
		}
	
		return vData
	}
	
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

}
