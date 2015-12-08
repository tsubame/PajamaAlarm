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
	
	
	func test_checkAllFileExists() {
		_sut.checkAllFileExists()
	}
	
	func test_outputVoiceListFiles() {
		let res = _sut.outputVoiceListFiles()
		XCTAssertTrue(res)
	}
	
	func test_getVoiceListsFromText() {
		let text = "【 深夜 】\r\n\r\n" +
		"・ひとこと_深夜_0.mp3       「んー……。すー……すー……」 <眠>\r\n\r\n" +
		"・ひとこと_深夜_1-0.mp3       「んー……。すー……すー……」 <眠>\r\n" +
		"・ひとこと_深夜_1-1.mp3       「んー……。すー……すー……」 <眠>\r\n\r\n" +
		"・ひとこと_深夜_2.mp3       「んー……。すー……すー……」 <眠>\r\n\r\n"
		
		let voiceLists = _sut.getVoiceListsFromText(text)
		XCTAssertNotEqual(voiceLists.count, 0, "")
		XCTAssertEqual(voiceLists.count, 3)
		
		print(voiceLists)
	}
	
    func test_loadDatasFromVoiceTextFile() {
		let fileName = "ひとこと"
        let res = _sut.loadDatasFromVoiceTextFile(fileName)
		
		for (key, vDatas) in res {
			print(key)
			for vData in vDatas {
				print(vData)
			}
		}
    }
	
	func test_loadVoiceListToDict() {
		let fileNames = ["ひとこと", "おはようボイス", "挨拶"]
		for fileName in fileNames {
			let res = _sut.loadVoiceListToDict(fileName)
			XCTAssertNotEqual(res.count, 0, "")

			for (_, vDatas) in res {
				XCTAssertNotEqual(vDatas.count, 0, "")
				
				for datas in vDatas {
					XCTAssertNotEqual(datas.count, 0, "")
					
					if 1 < datas.count {
						print(datas)
					}
				}
			}
		}
	}
	
	/*
	func test_loadDatasFromVoiceListFile() {
		let fileNames = ["ひとこと", "おはようボイス", "挨拶"]
		for fileName in fileNames {
			let res = _sut.loadDatasFromVoiceListFile(fileName)
			XCTAssertNotEqual(res.count, 0, "")
			
			for (key, vDatas) in res {
				//print(key)
				XCTAssertNotEqual(vDatas.count, 0, "")
				
				for vData in vDatas {
					//print(vData)
				}
			}
		}
	}*/
	
	/*
	func testOutputNewFiles() {
		let res = _sut.outputNewFiles()
		XCTAssertNotNil(res)
	}*/
	

	
	func test_outputFormatFiles() {
		let res = _sut.outputFormatFiles()
		XCTAssertTrue(res)
	}
	
	func test_loadVoiceTextFileAndSplit() {
		//_sut.outputFormatFiles()
		let res = _sut.loadVoiceTextFileAndSplit("おはようボイス")
		XCTAssertNotNil(res)
	}
	
	/*
	func test_loadDatasFromFile() {
		let res = _sut.loadDatasFromVoiceTextFile(<#T##fileName: String##String#>)("ひとこと")
		print(res)
	}*/
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
