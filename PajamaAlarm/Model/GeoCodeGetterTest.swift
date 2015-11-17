//
//  GeoCodeGetterTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/16.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class GeoCodeGetterTest: XCTestCase {
	
	var _sut = GeoCodeGetter()
	
    override func setUp() {
        super.setUp()
		
        _sut = GeoCodeGetter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetGeoCode() {
		var expectation = self.expectationWithDescription("")
		
		_sut.getGeoCode()
		
		
		dispatchAfterByDouble(2.0, closure: {
			print(self._sut._latitude)
		})
		
		self.waitForExpectationsWithTimeout(4.0, handler: nil)
    }
	
	/*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
