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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testUpdateWeather() {
		//_latitude  = "32.74"
		//_longiTude = "129.87"
		let expectation = self.expectationWithDescription("fetch posts")
		
		_sut.updateWeather({_, _ in
			//XCTAssertNotNil(lat, "結果がnilではないこと")
			expectation.fulfill()
		})

		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	
	func testGetCurrentWeather() {
		let expectation = self.expectationWithDescription("")
		
		_sut.getCurrentWeather({
			//XCTAssertNotNil(lat, "結果がnilではないこと")
			print(self._sut._currentWeather)
			expectation.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	
	func testGet3HourWeather() {
		let expectation = self.expectationWithDescription("")
		
		_sut.get3HourWeather({ hd in
			//XCTAssertNotNil(lat, "結果がnilではないこと")
			print(hd)
			expectation.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	
	func testGetDailyWeather() {
		let expectation = self.expectationWithDescription("")
		
		_sut.getDailyWeather({ wd in
			//XCTAssertNotNil(lat, "結果がnilではないこと")
			print(wd)
			expectation.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	}
	
	func testConvertToDict() {
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
	
	func testWriteToPlist() {
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

    func testPref() {
		let user = [
			"Name": "Siro Chro",
			"Age": "20",
			"Sex": "male",
		]
		
		let nsDic = user as NSDictionary
		
		var path = (NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents")
		path = (path as NSString).stringByAppendingPathComponent("prefTest23")
		//let res  = nsDic.writeToFile(path, atomically: true)
		let data = NSKeyedArchiver.archivedDataWithRootObject(nsDic)
		data.writeToFile(path, atomically: true)
		
		/*
		if res == true {
			print("success!")
		} else {
			print("failure!")
		}*/
		//let pref = NSUserDefaults.standardUserDefaults()
		//pref.setObject(_sut, forKey: "testPref")
		//pref.synchronize()
        /*
        var expectation = self.expectationWithDescription("fetch posts")
        
        self._sut.getWeatherOfTokyo()
        XCTAssertFalse(self._sut.hasError(), "エラーがないこと")
        
        var w = [String: String]()
        
        //expectation.fulfill()
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(6.5 * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), {
                w = self._sut._weatherTokyo
                expectation.fulfill()
        })
        self.waitForExpectationsWithTimeout(7.0, handler: nil)

        println(w)
        XCTAssertNotEqual(w.count, 0, "0件以上の結果が帰ってくること")
        */
    }


}
