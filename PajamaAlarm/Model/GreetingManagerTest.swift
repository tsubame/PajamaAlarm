//
//  GreetingManagerTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/23.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class GreetingManagerTest: XCTestCase {
	
	var _sut: GreetingManager!
	
    override func setUp() {
        super.setUp()
		
		_sut = GreetingManager()
		_sut.errorMessage  = ""
		_sut._textFileName = "greeting.txt"
		_sut._nickname     = "お姉ちゃん"
	}
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testPrintFileNamesAndTexts() {
		_sut.printFileNamesAndTexts()
	}
	
	func testLoadTextFileAndSplit() {
		_sut.loadTextFileAndSplit()
	}
	
	func testCheckAllFileExists() {
		_sut.checkAllFileExists()
		print(_sut.errorMessage)
	}
	
	func testGetRandomGreeting() {
		for _ in 0...20 {
			let text = _sut.getRandomGreeting()
			XCTAssertNotNil(text)
			print(text!)
		}
	}
	
    func testGetTimezoneFromText() {
		let texts   = [ "【 朝 】", "【昼】", "【 夜  】\naaa【】", " a【深夜】" ]
		let expects = [ "朝", "昼", "夜", "深夜" ]

		for (i, text) in texts.enumerate() {
			let res = _sut.getTimezoneFromText(text)
			XCTAssertEqual(res, expects[i])
			XCTAssertNotNil(res)
		}
		
		let wrongTexts = [ "【  】", "【", "【】"]
		for text in wrongTexts {
			let res = _sut.getTimezoneFromText(text)
			XCTAssertNil(res)
		}
    }
	
	func testGetVoiceWordsFromText() {
		let text    = "「こんにちは」（小声）　\n「ありがとう」"
		let expects = [ "こんにちは", "ありがとう"]
		
		let results = _sut.getVoiceWordsFromText(text)
		XCTAssertEqual(expects, results)
		
		//print(results)
	}
    
    func testExample() {
        var voices = [VoiceData]()
		for v in voices {
			print(v.text)
		}
		
		var allVoices = [String: [VoiceData]]()
		
		for (key, vs) in allVoices {
			for v in vs {
				
			}
		}
    }
    
}
