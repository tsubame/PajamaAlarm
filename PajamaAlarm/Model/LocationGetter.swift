//
//  LocationGetter.swift
//
//  位置情報を取得するクラス　天気取得前に実行
//
//  Created by hideki on 2014/11/06.
//
// （使い方）
//
//  let getter = LocationGetter()
//  getter.exec { (lat, long) -> () in
//    print(lat)
//    print(long)
//  }
//

import Foundation
import CoreLocation

class LocationGetter: NSObject, CLLocationManagerDelegate {

	// 定数
	let MAX_EXEC_SECOND: UInt64 = 4		// この秒数以内に位置情報を取得できなければ終了
	let LOC_TIMER_INTERVAL      = 0.1	// タイマー実行間隔
	
	// プライベート変数
    var _latitude : CLLocationDegrees? = nil	// 緯度
    var _longitude: CLLocationDegrees? = nil	// 経度
	var _locManager = CLLocationManager()
	

	
    // 初期処理
    override init() {
        super.init()
		_locManager.delegate = self
		
		// AppDelegateにも書くべき？
        getAuthorization()
    }
	
	// 位置情報を取得し、コールバック関数に渡す （使い方）locationGetter.exec { (lat, long) -> () in  print(lat)  }
	func exec(onComplete: (lat: CLLocationDegrees?, long: CLLocationDegrees?) -> ()) {
		startGetLocation()

		dispatch_after(MAX_EXEC_SECOND, dispatch_get_main_queue(), {
			//self.stopGetLocation()
			onComplete(lat: self._latitude, long: self._longitude)
		})
	}
	
	// 位置情報の使用許可ダイアログを表示
	func getAuthorization() {
		if NSFoundationVersionNumber_iOS_7_1 < floor(NSFoundationVersionNumber) {
			if _locManager.respondsToSelector("requestWhenInUseAuthorization") {
				_locManager.requestWhenInUseAuthorization() //_locManager.requestAlwaysAuthorization()
			}
		}
	}
	
	//======================================================
	// 位置情報関連
	//======================================================
	
	// 位置情報の取得を開始
	func startGetLocation() {
		if !CLLocationManager.locationServicesEnabled() {
			print("ERROR! 位置情報が取得できません")
			return
		}
		
		_latitude  = nil
		_longitude = nil
		_locManager.startUpdatingLocation()
		//self._timer = NSTimer.scheduledTimerWithTimeInterval(LOC_TIMER_INTERVAL, target: self, selector: "checkGetLocationCompleted:", userInfo: nil, repeats: true)

		print("位置情報の取得を開始します。")
	}
	
	// 位置情報取得を終了
	func stopGetLocation() {
		if !CLLocationManager.locationServicesEnabled() {
			return
		}
		
		_locManager.stopUpdatingLocation()
		print("位置情報の取得を終了します。")
		if _latitude == nil {
			//print("位置情報を取得できませんでした。")
		}
	}

	// PHPで都市の緯度、経度を取得
	func getCityGeoByIP(onComplete: (lat: String?, long: String?) -> ()) {
		// for Android
		let GEO_API_URL        = "http://taltal.catfood.jp/php/getCity.php"	 // 緯度、経度取得用API
		
		let nsUrl = NSURL(string: GEO_API_URL)
		let req   = NSURLRequest(URL: nsUrl!)
		
		print("都市の緯度、経度を取得中...\(GEO_API_URL)")
		
		NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {
			res, data, error in
			
			var lat: String?  = nil
			var long: String? = nil
			
			if error == nil {
				let json = JSON(data: data!)
				lat  = json["cityLatitude"].stringValue
				long = json["cityLongitude"].stringValue
			} else {
				print("通信エラー\(error!.description)")
			}
			
			onComplete(lat: lat, long: long)
		}
	}
    
    //===========================================================
    // CLLocationManagerDelegate
    //===========================================================
    
    // 位置情報更新時に呼ばれる
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations[0]
		
		if _latitude == nil {
			_latitude  = location.coordinate.latitude
			_longitude = location.coordinate.longitude
			print("位置情報を取得しました。 \(_latitude!) \(_longitude!)")
		}
		
		_locManager.stopUpdatingLocation()
	}

    
    // 位置情報取得失敗時に呼ばれる
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSOperationQueue.mainQueue().addOperationWithBlock{
            print("位置情報を取得できませんでした")
			self._locManager.stopUpdatingLocation()
        }
    }
    
    // 方位情報更新時に呼ばれる
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //print("方位情報を取得しました")
        //_heading = newHeading.trueHeading
    }
	
	
	
	
	//var _timer: NSTimer?    //
	//var _timerExecCount = 0	// タイマー処理の実行回数
	
	
	/*
	// タイマー定期処理 位置情報取得が終わったかを確認
	func checkGetLocationCompleted(timer: NSTimer) {
	_timerExecCount++
	
	if _latitude != nil || Int(MAX_EXEC_SECOND) * Int(1 / LOC_TIMER_INTERVAL) <= _timerExecCount {
	_timer?.invalidate()
	stopGetLocation()
	}
	}*/
	
	
	
}