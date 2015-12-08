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
	
	func testUpdateDailyWeatherAndWriteFile() {
		let expect = self.expectationWithDescription("")
		
		_sut.updateDailyWeatherAndWriteFile( { success in
			XCTAssertTrue(success)
			expect.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testRead() {
		let res = _sut.read()
		print(res)
		//XCTAssertTrue(res)
	}
	
	func testReadWeatherDataAfterNow() {
		let res = _sut.readWeatherDataAfterNow()
		//print(res)
		
		for data in res {
			print(data)
		}
		//XCTAssertTrue(res)
	}
	
	func testReadArrayFromPlist() {
		//let res = _sut.readArrayFromPlist()
	}
	
	func testRenamePastFiles() {
		let res = _sut.renamePastFiles("dailyWeather")
		
		XCTAssertTrue(res)
	}
	
	func test_gatherWeatherDatasAndWrite() {
		let longs = ["129.87", "132.45", "139.69", "140.8719", "141.346939",]
		let lats  = ["32.74",  "34.39",  "35.689", "38.26889", "43.06", ]
		
		for (i, lat) in lats.enumerate() {
			let pref = NSUserDefaults.standardUserDefaults()
			pref.setObject(lat, forKey: "latitude")
			pref.setObject(longs[i], forKey: "longitude")
			pref.synchronize()
			
			let ex = self.expectationWithDescription("")
			
			_sut.gatherWeatherDatasAndWrite() { success in
				XCTAssertTrue(success)
				ex.fulfill()
			}
			
			self.waitForExpectationsWithTimeout(4.0, handler: nil)
		}
	}
}
