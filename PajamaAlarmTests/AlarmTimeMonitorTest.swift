//
//  AlarmTimeMonitorTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/24.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class AlarmTimeMonitorTest: XCTestCase {
	
	var _sut: AlarmTimeMonitor!
	
    override func setUp() {
        super.setUp()
		
		_sut = AlarmTimeMonitor()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testNotif() {
		postLocalNotif(NOTIF_SET_ALARM_ON)
		
		let sec = 85.0
		let expect = self.expectationWithDescription("")
		self.waitForExpectationsWithTimeout(Double(sec + 3), handler: nil)
	}
    
    func testStartBGTask() {
		let sec = 85.0
		
		let date = NSDate(timeInterval: sec, sinceDate: NSDate())
		writePref(date, key: PREF_KEY_ALARM_TIME)

		let expect = self.expectationWithDescription("")
		_sut.startBGTask()
		
		/*
		dispatchAfterByDouble(sec, closure: {
			self._sut.startTimeMonitoring()
		})*/
		
		self.waitForExpectationsWithTimeout(Double(sec + 3), handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
