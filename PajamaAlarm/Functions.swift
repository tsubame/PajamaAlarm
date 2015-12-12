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

// 指定したパスにあるファイルからテキストデータを読み込む
func loadTextFromPath(filePath: String, encoding: UInt = NSUTF8StringEncoding) -> String {
	/*
	var ofType = ""
	if !filePath.containsString(".txt") {
		ofType = ".txt"
	}
	
	let file = NSBundle.mainBundle().pathForResource(fileName, ofType: ofType)
	if file == nil {
		return ""
	}
	*/
	return NSString(data: NSData(contentsOfFile: filePath)!, encoding: encoding) as! String
}

//======================================================
// その他
//======================================================

// 正規表現で検索　　（使い方）searchWithRegex(text, ptn: "<(.+)>", rangeAtIndex: 1)
func searchWithRegex(text: String, ptn: String, rangeAtIndex: Int = 0) -> String {
	let nsText = text as NSString
	
	let regex  = try? NSRegularExpression(pattern: ptn, options: NSRegularExpressionOptions())
	let result = regex?.firstMatchInString(text, options: NSMatchingOptions(), range: NSMakeRange(0, nsText.length))
	
	if result != nil {
		if 1 < result?.numberOfRanges {
			return nsText.substringWithRange((result?.rangeAtIndex(rangeAtIndex))!)
		}
		
		return nsText.substringWithRange((result?.rangeAtIndex(0))!)
	}
	
	return ""
}

// 正規表現で置換
func replaceWithRegex(text: String, ptn: String, replaceStr: String) -> String {
	let nsText = text as NSString
	
	return text.stringByReplacingOccurrencesOfString(ptn, withString: replaceStr, options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
}

// Double型を指定できる dispatch_after   （使い方）delay(2.0) { println("test.") }
func delay(delaySec: Double, closure:()->()) {
	dispatch_after(
		dispatch_time(
			DISPATCH_TIME_NOW,
			Int64(delaySec * Double(NSEC_PER_SEC))
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



/*
func dispatchAfterByDouble(delay:Double, closure:()->()) {
dispatch_after(
dispatch_time(
DISPATCH_TIME_NOW,
Int64(delay * Double(NSEC_PER_SEC))
),
dispatch_get_main_queue(), closure)
}
*/
