//
//  ShortTalkManagerTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/24.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class ShortTalkBuilderTest: XCTestCase {
	
	var _sut: ShortTalkBuilder!
	
    override func setUp() {
        super.setUp()
		
		writePref("兄さん", key: PREF_KEY_NICKNAME)
		_sut = ShortTalkBuilder()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func test_getShortTalkDatas() {
		for _ in 0...20 {
			let voices = _sut.getShortTalkDatas()
			XCTAssertNotEqual(voices.count, 0)
			
			if 2 <= voices.count {
				print(voices)
			}
		}
	}
	
	
	/*
    func testGetTalkVoiceData() {
		for _ in 0...20 {
			let vd = _sut.getShortTalkData()()
			XCTAssertNotNil(vd)
			print("「\(vd!.text)」")
		}
    }
	
	func testGetGreetingVoiceData() {
		for h in 0...24 {
			let date = NSDate(timeInterval: 3600 * Double(h), sinceDate: NSDate())
			
			for _ in 0...10 {
				let vd = _sut.getGreetingVoiceData(date)
				XCTAssertNotNil(vd)
				print("「\(vd!.text)」")
			}
		}
	}*/
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
