//
//  WeatherFileManager.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/20.
//
//  お天気データを .plist に読み書きするクラス。
//
//　（依存ファイル）
//		・WeatherGetter.swift
//		・Constants.swift
//
//　（使い方）
//		let writer = WeatherFileWriter()
//		writer.updateAndWrite( { success in
//			if success == true {
//				print("書き出し成功")
//			}
//		})
//

import UIKit

class WeatherFileManager: NSObject {
	
	let DAILY_FILE_NAME = "dailyWeather" // 保存先のファイル名
	let HOUR_FILE_NAME  = "3hourWeather"
	let FILE_SUFFIX     = ".plist"
	
	var _wGetter       = WeatherGetter()
	
	var errorMessage: String?
	
	//
	func updateAndWrite(onComplete: (success: Bool) -> ()) {
		updateWeatherAndWriteFile() {res in
			onComplete(success: res)
		}
	}
	
	//
	func read() -> [WeatherData] {
		var weatherDatas = [WeatherData]()

		let path = PATH_TO_DOCUMENTS.stringByAppendingPathComponent(HOUR_FILE_NAME + FILE_SUFFIX)
		let dict = NSDictionary(contentsOfFile: path)!
		
		// 要ソート
		
		for (key, data) in dict.enumerate() {
			//var wData = WeatherData()
			//print(key)
			print(key)
			print(data)
			//let tempStr = String(data["temp"])
			//wData.weather = String(data["weather"])
			//wData.temp    = Double(tempStr)!
			//wData.updateDate = NSDate(data["updateDate"])
			
			//var fmt: NSDateFormatter = NSDateFormatter()
			//fmt.locale     = NSLocale(localeIdentifier: "ja")
			//fmt.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
			//let dt = fmt.dateFromString(String(data["weatherDate"]))!
			
			//print(dt)
			
			//weatherDatas.append(wData)
		}
		
		return weatherDatas
	}
	
	// 天気の更新とファイルへの書き出し
	func updateWeatherAndWriteFile(onComplete: (success: Bool) -> ()) {
		renamePastFiles(HOUR_FILE_NAME)
		
		_wGetter.get3HourWeather({ wDatas in
			// 辞書型に変換
			let dict = self.structsToNSDict(wDatas)
			
			// 書き出し
			let path = PATH_TO_DOCUMENTS.stringByAppendingPathComponent(self.HOUR_FILE_NAME + self.FILE_SUFFIX)
			let res  = self.writeToFile(dict, path: path)
			
			onComplete(success: res)
		})
	}
	
	func updateDailyWeatherAndWriteFile(onComplete: (success: Bool) -> ()) {
		// 過去のファイルの移動
		renamePastFiles(DAILY_FILE_NAME)
		
		_wGetter.getDailyWeather({ wDatas in
			// 辞書型に変換
			let dict = self.structsToNSDict(wDatas)
			
			// 書き出し
			let path = PATH_TO_DOCUMENTS.stringByAppendingPathComponent(self.DAILY_FILE_NAME)
			let res  = self.writeToFile(dict, path: path)
			
			onComplete(success: res)
		})
	}
	
	//
	func structsToNSDict(weatherDatas: [WeatherData]) -> NSDictionary {
		var dics = [String: [String: NSObject]]()
		
		for w in weatherDatas {
			let dic     = w.toDictionary()
			let date    = dic["weatherDate"]!
			let dateStr = "\(date)"
			dics[dateStr] = dic
		}
		
		return dics as NSDictionary
	}
	
	//
	func writeToFile(nsDict: NSDictionary, path: String) -> Bool {
		let res = nsDict.writeToFile(path, atomically: true)
		
		if res == true {
			print("保存先: \(path)")
		}
		
		return res
	}
	
	// 過去のファイルのリネーム
	func renamePastFiles(fileName: String) -> Bool {
		errorMessage = nil
		
		let MAX_FILE_COUNT   = 7
		//let FILE_NAME_PREFIX = "dailyWeather"
		//let FILE_NAME_SUFFIX = ".plist"
		var filePath = ""
		
		let manager = NSFileManager()
		
		do {
			for (var i = MAX_FILE_COUNT; 0 <= i; i--) {
				
				if i == 0 {
					filePath = PATH_TO_DOCUMENTS.stringByAppendingPathComponent("\(fileName)\(FILE_SUFFIX)")
				} else {
					filePath = PATH_TO_DOCUMENTS.stringByAppendingPathComponent("\(fileName)\(i)\(FILE_SUFFIX)")
				}
				
				if manager.fileExistsAtPath(filePath) {
					let toPath   = PATH_TO_DOCUMENTS.stringByAppendingPathComponent("\(fileName)\(i + 1)\(FILE_SUFFIX)")
					try manager.moveItemAtPath(filePath, toPath: toPath)
				}
			}
			
		} catch {
			print("error.");
			errorMessage = "ファイルのコピーに失敗しました。"
			
			return false
		}
		
		return true
	}

}
