//
//  LocationGetterTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/17.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class LocationGetterTest: XCTestCase {
	
	var _sut = LocationGetter()
	
	override func setUp() {
		super.setUp()
		
		_sut = LocationGetter()
	}
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExec() {
		let expectation = self.expectationWithDescription("fetch posts")
		
		_sut.exec { (lat, long) -> () in
			print(lat)
			XCTAssertNotNil(lat, "結果がnilではないこと")
			expectation.fulfill()
		}

		self.waitForExpectationsWithTimeout(5.1, handler: nil)
	
		//println(w)
		//XCTAssertNotEqual(w.count, 0, "0件以上の結果が帰ってくること")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
