//
//  MorningVoiceManagerTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/24.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class MorningVoiceBuilderTest: XCTestCase {
    
	var _sut: MorningVoiceBuilder!
	
	override func setUp() {
		super.setUp()
		writePref("兄さん", key: PREF_KEY_NICKNAME)
		_sut = MorningVoiceBuilder()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func test_getMorningVoiceDatas() {
		let params = ["晴れ", "曇り", "雨", "豪雨"]
		
		for p in params {
			let vDatas = _sut.getMorningVoiceDatas(p)
			for vData in vDatas {
				print(vData.text)
			}
			print("")
		}
		
		// 引数なし
		let vDatas = _sut.getMorningVoiceDatas()
		for vData in vDatas {
			print(vData.text)
		}
	}
	
	func test_getMorningVoiceDatasInOtherNickname() {
		writePref("お姉ちゃん", key: PREF_KEY_NICKNAME)
		for _ in 0...20 {
			let vDatas = _sut.getMorningVoiceDatas("晴れ")
			for vData in vDatas {
				print(vData.text)
			}
			print("")
		}
		
		// 誤った名前
		writePref("お兄ちゃん", key: PREF_KEY_NICKNAME)
		for _ in 0...20 {
			let vDatas = _sut.getMorningVoiceDatas("晴れ")
			for vData in vDatas {
				print(vData.text)
			}
			print("")
		}
	}
	
	func test_getHeadDatas() {
		for _ in 0...20 {
			let res = _sut.getHeadDatas()
			XCTAssertNotEqual(res.count, 0, "")
		}
	}
	
	func test_loadVoiceDataFromFile() {
		_sut.loadVoiceDataFromFile()
		//print(_sut._voiceDict)
	}
	
	/*
	func test_loadVoiceData() {
		_sut.loadVoiceData()
	}
	
	func test_getHeadVoiceData() {
		let count = 20
		
		for _ in 0...count {
			let vData = _sut.getHeadVoiceData()
			print("・" + vData.fileName)
			print(vData.text + "\n")
		}
	}
	
	func test_getWeatherVoiceDatas() {
		let params = ["晴れ", "曇り", "雨", "豪雨"]
		
		for p in params {
			let results = _sut.getWeatherVoiceDatas(p)
			XCTAssertNotEqual(results.count, 0)
			print("\(p)")
			
			for res in results {
				print("\(res.fileName)")
			}
		}
		
		let wrongParams = ["雷雨", "雪"]
		
		for p in wrongParams {
			let results = _sut.getWeatherVoiceDatas(p)
			XCTAssertEqual(results.count, 0)
		}
	}
	
	func test_getWeatherVoiceData() {
		let params = ["晴れ", "曇り", "雨", "豪雨"]
		
		for p in params {
			let data = _sut.getWeatherVoiceData(p)
			XCTAssertNotNil(data)
			print("\(p): \(data!.fileName)")
		}
		
		let wrongParams = ["雷雨", "雪"]
		
		for p in wrongParams {
			let vData = _sut.getWeatherVoiceData(p)
			XCTAssertNil(vData)
			print("\(p): \(vData)")
		}
	}*/

	
}
