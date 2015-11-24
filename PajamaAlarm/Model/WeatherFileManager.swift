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
	
	// 定数
	let DAILY_FILE_NAME = "dailyWeather" // 保存先のファイル名　日毎の気温
	let HOUR_FILE_NAME  = "3hourWeather" // 保存先のファイル名　3時間毎の気温
	let FILE_SUFFIX     = ".plist"		 // 拡張子
	
	// プライベート変数
	var _wGetter = WeatherGetter()
	
	
	//======================================================
	// 天気の更新、書き出し
	//======================================================
	
	//
	func updateAndWrite(onComplete: (success: Bool) -> ()) {
		updateWeatherAndWriteFile() {res in
			onComplete(success: res)
		}
		
		updateDailyWeatherAndWriteFile() {res in
			onComplete(success: res)
		}
	}
	
	// 天気の更新とファイルへの書き出し
	func updateWeatherAndWriteFile(onComplete: (success: Bool) -> ()) {
		renamePastFiles(HOUR_FILE_NAME)
		
		_wGetter.get3HourWeather({ wDatas in
			let datas = self.structsToNSArray(wDatas)
			let path = PATH_TO_DOCUMENTS.stringByAppendingPathComponent(self.HOUR_FILE_NAME + self.FILE_SUFFIX)
			let res  = self.writeArrayToFile(datas, path: path)
			
			onComplete(success: res)
		})
	}
	
	// 天気の更新とファイルへの書き出し 日毎の天気
	func updateDailyWeatherAndWriteFile(onComplete: (success: Bool) -> ()) {
		// 過去のファイルの移動
		renamePastFiles(DAILY_FILE_NAME)
		
		_wGetter.getDailyWeather({ wDatas in
			let datas = self.structsToNSArray(wDatas)
			let path = PATH_TO_DOCUMENTS.stringByAppendingPathComponent(self.DAILY_FILE_NAME + self.FILE_SUFFIX)
			let res  = self.writeArrayToFile(datas, path: path)
			
			onComplete(success: res)
		})
	}
	
	//======================================================
	// ファイルからの読み込み
	//======================================================
	
	//
	func readWeatherDataAfterNow() -> [WeatherData] {
		let GET_COUNT = 4
		var weatherDatas = [WeatherData]()
		
		let datas = readArrayFromPlist(HOUR_FILE_NAME)
		if datas == nil {
			return weatherDatas
		}
		
		for d in datas! {
			let wData = nsDictToStruct(d as! NSDictionary)
			let res = CALENDAR.compareDate(NSDate(), toDate: wData.weatherDate, toUnitGranularity: NSCalendarUnit.Second)

			if res == .OrderedAscending {
				weatherDatas.append(wData)
			}
			
			if GET_COUNT <= weatherDatas.count {
				break
			}
		}
		
		return weatherDatas
	}

	func readArrayFromPlist(var fileName: String) -> NSArray? {
		if fileName.containsString(FILE_SUFFIX) == false {
			fileName += FILE_SUFFIX
		}
		
		let path = PATH_TO_DOCUMENTS.stringByAppendingPathComponent(fileName)
		
		let datas = NSArray(contentsOfFile: path)
		if datas == nil {
			print(".plistの読み込みエラーです。")
			return nil
		}
		
		return datas
	}
	
	func nsDictToStruct(data: NSDictionary) -> WeatherData {
		var wData = WeatherData()
		// 日時をフォーマット
		let fmt         = NSDateFormatter()
		fmt.dateFormat  = "yyyy-MM-dd HH:mm:ss"
		
		if data["temp"] == nil || data["weather"] == nil || data["weatherDate"] == nil || data["updateDate"] == nil {
			print("キーが存在しません。")
		}
		
		let t  = String(data["temp"]!)
		let w  = String(data["weather"]!)
		let wd = String(data["weatherDate"]!)
		let ud = String(data["updateDate"]!)
		
		wData.weather     = w
		wData.temp        = Double(t)!
		wData.weatherDate = fmt.dateFromString(wd)!
		wData.updateDate  = fmt.dateFromString(ud)!
		
		return wData
	}
	
	//
	func read() -> [WeatherData] {
		var weatherDatas = [WeatherData]()
		let GET_COUNT = 4

		let path = PATH_TO_DOCUMENTS.stringByAppendingPathComponent(HOUR_FILE_NAME + FILE_SUFFIX)
		let dict = NSDictionary(contentsOfFile: path)!

		let ar = NSArray(contentsOfFile: path)!
		print(ar)
		
		let keys = getSortedKeys(dict)
		
		for (i, k) in keys.enumerate() {
			if GET_COUNT <= i {
				break
			}
			
			var wData = WeatherData()
			let temp        = String(dict[k]!["temp"]!)
			let weather     = String(dict[k]!["weather"]!)
			let weatherDate = String(dict[k]!["weatherDate"]!)
			let updateDate  = String(dict[k]!["updateDate"]!)
			// 日時をフォーマット
			let fmt         = NSDateFormatter()
			fmt.dateFormat  = "yyyy-MM-dd HH:mm:ss"
			
			wData.temp        = Double(temp)!
			wData.weather     = weather
			wData.weatherDate = fmt.dateFromString(weatherDate)!
			wData.updateDate  = fmt.dateFromString(updateDate)!
			
			weatherDatas.append(wData)
		}
		
		return weatherDatas
	}
	
	func getSortedKeys(dict: NSDictionary) -> [String] {
		var keys = [String]()
		for (k, _) in dict {
			keys.append(k as! String)
		}
		
		keys = keys.sort()
		
		return keys
	}
	

	//
	func structsToNSDict(weatherDatas: [WeatherData]) -> NSDictionary {
		var dics = [String: [String: NSObject]]()
		
		for w in weatherDatas {
			let dic     = w.toDictionary()
			let date    = dic["weatherDate"]
			let dateStr = "\(date!)"
			dics[dateStr] = dic
		}
		
		return dics as NSDictionary
	}
	
	//
	func structsToNSArray(weatherDatas: [WeatherData]) -> NSArray {
		var datas = [[String: NSObject]]()
		
		for w in weatherDatas {
			let dic     = w.toDictionary()
			//let date    = dic["weatherDate"]
			//let dateStr = "\(date!)"
			datas.append(dic)
		}
		
		return datas as NSArray
	}
	
	//
	func writeArrayToFile(datas: NSArray, path: String) -> Bool {
		let res = datas.writeToFile(path, atomically: true)
		
		if res == true {
			print("保存先: \(path)")
		}
		
		return res
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
		//errorMessage = nil
		
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
			//errorMessage = "ファイルのコピーに失敗しました。"
			
			return false
		}
		
		return true
	}

}
