//
//  WeatherGetterTest.swift
//  BedsideVoice
//
//  Created by hideki on 2014/12/06.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import UIKit
import XCTest

class WeatherGetterTest: XCTestCase {

    var _sut = WeatherGetter()
    
    override func setUp() {
        super.setUp()
        _sut = WeatherGetter()
		
		let pref = NSUserDefaults.standardUserDefaults()
		pref.setObject("32.74", forKey: "latitude")
		pref.setObject("129.87", forKey: "longitude")
		pref.synchronize()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func test_exec() {
		let ex = self.expectationWithDescription("")
		
		_sut.exec() { wDatas in
			XCTAssertNotEqual(wDatas.count, 0)
			ex.fulfill()

			for data in wDatas {
				print(data)
			}
		}

		self.waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func test_exec_forError() {
		// 緯度、経度がない時
		let pref = NSUserDefaults.standardUserDefaults()
		pref.setObject(nil, forKey: "latitude")
		pref.setObject(nil, forKey: "longitude")
		pref.synchronize()
		
		let ex = self.expectationWithDescription("")
		
		_sut.exec() { wDatas in
			XCTAssertEqual(wDatas.count, 0)
			ex.fulfill()
			
			for data in wDatas {
				print(data)
			}
		}
		
		self.waitForExpectationsWithTimeout(3.0, handler: nil)
	}
	
	func test_getDailyWeather() {
		let ex = self.expectationWithDescription("")
		
		_sut.getDailyWeather() { wd in
			XCTAssertNotEqual(wd.count, 0, "結果が0件以上であること")
			ex.fulfill()
			
			for data in wd {
				print(data)
			}
			
			print(self._sut._cityName)
		}
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	
	func test_getCurrentWeather() {
		let expectation = self.expectationWithDescription("")
		
		_sut.getCurrentWeather({
			//XCTAssertNotNil(lat, "結果がnilではないこと")
			print(self._sut._currentWeather)
			expectation.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	
	func test_get3HourWeather() {
		let expectation = self.expectationWithDescription("")
		
		_sut.get3HourWeather({ hd in
			//XCTAssertNotNil(lat, "結果がnilではないこと")
			print(hd)
			expectation.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	

	
	func test_convertToDict() {
		_sut._latitude  = "32.74"
		_sut._longiTude = "129.87"
		
		let expectation = self.expectationWithDescription("")
		
		_sut.getDailyWeather({ wd in
			wd.map{ w in
				var dic = w.toDictionary()
				print(dic)
			}
			expectation.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	
	func test_writeToPlist() {
		var path = (NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents")
		path = (path as NSString).stringByAppendingPathComponent("dailyWeather.plist")
		
		_sut._latitude  = "32.74"
		_sut._longiTude = "129.87"
		
		let expectation = self.expectationWithDescription("")
		
		var weatherDicts = [String: [String: NSObject]]()
		
		_sut.getDailyWeather({ wd in
			
			wd.map{ w in
				let dic = w.toDictionary()
				let wDate = dic["weatherDate"]!
				let wDateStr = "\(wDate)"
				weatherDicts[wDateStr] = dic

			}
			print(weatherDicts)
			var nsDict = weatherDicts as NSDictionary
			let res = nsDict.writeToFile(path, atomically: true)
			
			if res == true {
				expectation.fulfill()
			}
			
			print("保存先: \(path)")
		})
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}

	func test_getFromWG() {
		let ex = self.expectationWithDescription("")
		
		_sut.getFromWG() { w in
			print(w.weather)
			ex.fulfill()
		}
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}

	func test_writeYeasterdayData() {
			writePref("晴れ",	key: PREF_KEY_T_WEATHER)
			writePref(10.0,		key: PREF_KEY_T_MIN_TEMP)
			writePref(15.0,		key: PREF_KEY_T_MAX_TEMP)
			writePref(NSDate(timeIntervalSinceNow: -86400),  key: PREF_KEY_T_WEATHER_DATE)
	}
	
	func test_sslTest() {
		let ex = self.expectationWithDescription("")
		
		_sut.sslTest() { d in
			print(d)
			ex.fulfill()
		}
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}

}
