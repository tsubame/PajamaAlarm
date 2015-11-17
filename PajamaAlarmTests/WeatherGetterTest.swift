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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPref() {
		
		let pref = NSUserDefaults.standardUserDefaults()
		pref.setObject(_sut, forKey: "testPref")
		pref.synchronize()
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
