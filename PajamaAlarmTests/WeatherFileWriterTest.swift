//
//  WeatherFileWriterTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/18.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class WeatherFileWriterTest: XCTestCase {
	
	var _sut = WeatherFileWriter()
	
    override func setUp() {
        super.setUp()
		
		_sut = WeatherFileWriter()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUpdateWeatherAndWriteFile() {
		let expect = self.expectationWithDescription("")
		
		_sut.updateWeatherAndWriteFile( { success in
			XCTAssertTrue(success)
			expect.fulfill()
		})
		
		self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
	
}
