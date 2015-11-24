//
//  ConstantsAndFunctions.swift
//  関数定義用ファイル
//
//  Created by hideki on 2014/11/03.
//

import Foundation
import UIKit


//======================================================
// プリファレンス
//======================================================

// プリファレンスから読み込み
func readPref(key: String) -> AnyObject? {
	return NSUserDefaults.standardUserDefaults().objectForKey(key)
}

// プリファレンスに書き込み
func writePref(object: NSObject?, key: String) {
	let pref = NSUserDefaults.standardUserDefaults()
	pref.setObject(object, forKey: key)
	pref.synchronize()
}

//======================================================
// ローカル通知
//======================================================

// ローカル通知の発行
func postLocalNotif(notifName: String) {
	NSNotificationCenter.defaultCenter().postNotificationName(notifName, object: nil)
}

// ローカル通知のオブザーバーの追加
func addNotifObserver(notifName: String, closure:()->() ) {
	let notif = NSNotificationCenter.defaultCenter()
	
	notif.addObserverForName(notifName, object: nil, queue: nil, usingBlock: { _ in
		closure()
	})
}

//======================================================
// ファイル処理
//======================================================

// ファイルの存在確認
func isFileExists(fileName: String) -> Bool {
	let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "")
	
	if path == nil {
		return false
	}
	
	return true
}

// リソースフォルダ内にあるファイルからテキストデータを読み込む
func loadTextFromFile(fileName: String, encoding: UInt = NSUTF8StringEncoding) -> String {
	var ofType = ""
	if !fileName.containsString(".txt") {
		ofType = ".txt"
	}
	
	let file = NSBundle.mainBundle().pathForResource(fileName, ofType: ofType)
	if file == nil {
		return ""
	}
	
	return NSString(data: NSData(contentsOfFile: file!)!, encoding: encoding) as! String
}

//======================================================
// その他
//======================================================

// Double型を指定できる dispatch_after   （使い方）dispatchAfterByDouble(2.0, { println("test.") })
func dispatchAfterByDouble(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

// 乱数取得 rand(3) → 0, 1, 2のどれかが返る
func rand(num: Int) -> Int {
    var result:Int
    result = Int(arc4random() % UInt32(num))
    
    return result
}

// ImageViewを作成
func makeImageView(frame: CGRect, image: UIImage) -> UIImageView {
    let imageView = UIImageView()
    imageView.frame = frame
    imageView.image = image
    
    return imageView
}

//UIntに16進で数値をいれるとUIColorが戻る関数　例: view.backgroundColor = UIColorFromRGB(0x123456)
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
	return UIColor(
		red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
		green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
		blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
		alpha: CGFloat(1.0)
	)
}

// 現在の時間帯を返す　早朝、朝、昼、夜、深夜
func getCurrentTimePeriod(date: NSDate? = nil) -> String {
	/* バグが有るため未使用
	let TIME_ZONE_NAMES = ["早朝": 4...5, "朝": 6...11, "昼": 12...17, "お昼": 12...17, "夜": 18...23, "深夜": 0...3]
	*/
	
	var tZones = ["早朝": 4...5]
	tZones["朝"]		= 6...11
	tZones["昼"]		= 12...17
	//tZones["お昼"]	= 12...17
	tZones["夜"]		= 18...23
	tZones["深夜"]	= 0...3
	
	var comps = CALENDAR.components([NSCalendarUnit.Hour], fromDate: NSDate())
	if date != nil {
		comps = CALENDAR.components([NSCalendarUnit.Hour], fromDate: date!)
	}
	
	for (time, timeRange) in tZones {
		for h in timeRange {
			if h == comps.hour {
				return time
			}
		}
	}
	
	return "昼"
}
