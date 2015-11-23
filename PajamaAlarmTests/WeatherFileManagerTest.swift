//
//  WeatherFileManager.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/20.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class WeatherFileManagerTest: XCTestCase {
    
	var _sut = WeatherFileManager()
	
	override func setUp() {
		super.setUp()
		
		_sut = WeatherFileManager()
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testUpdateAndWrite() {
		let expect = self.expectationWithDescription("")
		
		_sut.updateAndWrite( { success in
			XCTAssertTrue(success)
			expect.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testRead() {
		let res = _sut.read()
		
		//XCTAssertTrue(res)
	}
	
	func testRenamePastFiles() {
		let res = _sut.renamePastFiles("dailyWeather")
		
		XCTAssertTrue(res)
	}
}
