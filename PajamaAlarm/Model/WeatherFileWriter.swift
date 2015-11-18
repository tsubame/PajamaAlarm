//
//  WeatherFileWriter.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/18.
//
//  お天気データを .plist に書き出すクラス。
//　
//　（依存ファイル）
//		・WeatherGetter.swift
//		・Constants.swift
//
//　（使い方）
//		let writer = WeatherFileWriter()
//		writer.updateWeatherAndWriteFile( { success in
//			if success == true {
//				print("書き出し成功")
//			}
//		})
//

import UIKit

class WeatherFileWriter: NSObject {

	
	let DAILY_FILE_NAME = "dailyWeather.plist" // 保存先のファイル名
	var _wGetter       = WeatherGetter()
	
	
	// 天気の更新とファイルへの書き出し
	func updateWeatherAndWriteFile(onComplete: (success: Bool) -> ()) {
		
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
	func renamePastFiles() {
	
	}
}
