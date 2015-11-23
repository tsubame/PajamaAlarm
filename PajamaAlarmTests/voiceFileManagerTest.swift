//
//  voiceFileManagerTest.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/23.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import XCTest

class VoiceFileManagerTest: XCTestCase {
	
	var _sut: VoiceFileManager!
	
    override func setUp() {
        super.setUp()
		
		_sut = VoiceFileManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadVoiceDatasFromFile() {
		let fileName = "ひとこと"
        let res = _sut.loadVoiceDatasFromFile(fileName)
		
		for (key, vDatas) in res {
			print(key)
			for vData in vDatas {
				print(vData)
			}
		}
    }
	
	func testOutputNewFiles() {
		_sut.outputNewFiles()
	}
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
