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
	let MAX_EXEC_SECOND    = 3		// この秒数以内に位置情報を取得できなければ終了
	let LOC_TIMER_INTERVAL = 0.1	// タイマー実行間隔
	let GEO_API_URL        = "http://taltal.catfood.jp/php/getCity.php"	 // 緯度、経度取得用API
	
    var _latitude : CLLocationDegrees? = nil	// 緯度
    var _longitude: CLLocationDegrees? = nil	// 経度
    
    var _timer: NSTimer?
    var _timerExecCount = 0						// タイマー処理の実行回数
	var _errorMessage: String?					// エラーメッセージ
	
	var _locManager     = CLLocationManager()

    
    // 初期処理
    override init() {
        super.init()
		_locManager.delegate = self
		
		// iOS8〜のみ、以下の処理が必要
        if NSFoundationVersionNumber_iOS_7_1 < floor(NSFoundationVersionNumber) {
            //if #available(iOS 8.0, *) {
			if _locManager.respondsToSelector("requestWhenInUseAuthorization") {
				_locManager.requestWhenInUseAuthorization()
				//_locManager.requestAlwaysAuthorization()
			}
        }
		
		NSNotificationCenter.defaultCenter().addObserverForName("startGetLocation", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.startGetLocation()
        })
    }
	
	// 位置情報を取得し、コールバック関数に渡す	（使い方）locationGetter.exec { (lat, long) -> () in  print(lat)  }
	func exec(onComplete: (lat: CLLocationDegrees?, long: CLLocationDegrees?) -> ()) {
		startGetLocation()

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(MAX_EXEC_SECOND * Int(NSEC_PER_SEC))),
			dispatch_get_main_queue(), {
				onComplete(lat: self._latitude, long: self._longitude)
		})
	}
	
	// 位置情報の取得を開始
	func startGetLocation() {
		if !CLLocationManager.locationServicesEnabled() {
			print("ERROR! 位置情報が取得できません")
			return
		}
		
		_latitude  = nil
		_longitude = nil
		_locManager.startUpdatingLocation()
		
		self._timer = NSTimer.scheduledTimerWithTimeInterval(LOC_TIMER_INTERVAL, target: self, selector: "checkGetLocationCompleted:", userInfo: nil, repeats: true)
		
		print("位置情報の取得を開始")
	}
	
	// タイマー定期処理 位置情報取得が終わったかを確認
	func checkGetLocationCompleted(timer: NSTimer) {
		_timerExecCount++
		
		if _latitude != nil || MAX_EXEC_SECOND * Int(1 / LOC_TIMER_INTERVAL) <= _timerExecCount {
			_timer?.invalidate()
			_timer = nil
			stopGetLocation()
		}
	}
	
	// 位置情報取得を終了
    func stopGetLocation() {
        if CLLocationManager.locationServicesEnabled() {
            _locManager.stopUpdatingLocation()
        }
		
		if _latitude == nil {
			print("位置情報を取得できませんでした")
		}
		/*
        // 設定情報に書きこみ
        let pref = NSUserDefaults.standardUserDefaults()
        pref.setObject("\(_latitude)",  forKey: "latitude")
        pref.setObject("\(_longitude)", forKey: "longitude")
        pref.synchronize()
		*/
    }
        
    // 位置情報を返す
    func getLatitudeAndLogitude() -> (CLLocationDegrees?, CLLocationDegrees?) {
        return (_latitude, _longitude)
    }

	// 都市の緯度、経度を取得
	func getCityGeoByIP(onComplete: (lat: String?, long: String?, eMessage: String?) -> ()) {
		let nsUrl = NSURL(string: GEO_API_URL)
		let req   = NSURLRequest(URL: nsUrl!)
		
		print("都市の緯度、経度を取得中...\(GEO_API_URL)")
		
		NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) {
			res, data, error in
			
			var lat: String?  = nil
			var long: String? = nil
			
			if error == nil {
				self._errorMessage = nil
				let json = JSON(data: data!)
				lat  = json["cityLatitude"].stringValue
				long = json["cityLongitude"].stringValue
			} else {
				self._errorMessage = error!.description
				print("通信エラー\(self._errorMessage)")
			}
			
			onComplete(lat: lat, long: long, eMessage: self._errorMessage)
		}
	}
    
    //===========================================================
    // CLLocationManagerDelegate
    //===========================================================
    
    // 位置情報更新時に呼ばれる
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations[0]
		_latitude  = location.coordinate.latitude
		_longitude = location.coordinate.longitude
		
		print("位置情報を取得しました。 \(_latitude) \(_longitude)")
	}

    
    // 位置情報取得失敗時に呼ばれる
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSOperationQueue.mainQueue().addOperationWithBlock{
            print("位置情報を取得できませんでした")
        }
    }
    
    // 方位情報更新時に呼ばれる
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("方位情報を取得しました")
        //_heading = newHeading.trueHeading
    }
    
    
}