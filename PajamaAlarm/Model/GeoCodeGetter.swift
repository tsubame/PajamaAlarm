//
//  GeoCodeGetter.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/11/16.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit
import CoreLocation

class GeoCodeGetter: NSObject, CLLocationManagerDelegate {
	
	
	var _locManager: CLLocationManager!
	var _latitude:  CLLocationDegrees = 0.0
	var _longitude: CLLocationDegrees = 0.0
	
	override init() {
		super.init()
		_locManager = CLLocationManager()
		//_locManager.requestAlwaysAuthorization()
		_locManager.requestWhenInUseAuthorization()
		_locManager.delegate = self
	}
	
	func getGeoCode() {
		/*
		_locManager = CLLocationManager()
		//_locManager.requestAlwaysAuthorization()
		_locManager.requestWhenInUseAuthorization()
		_locManager.delegate = self
		
		print(CLLocationManager.locationServicesEnabled())
		*/
		if CLLocationManager.locationServicesEnabled() {
			_locManager.startUpdatingLocation()
			print(_locManager.location?.coordinate.latitude)
		}
	}
	
	//======================================================
	// CLLocationManagerDelegate
	//======================================================
	
	// 位置情報更新時に呼ばれる
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let loc = locations[0]
		_latitude  = loc.coordinate.latitude
		_longitude = loc.coordinate.longitude
		
		print(_latitude)
		print(_longitude)
	}
	
	// 位置情報取得失敗時に呼ばれる
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("ERROR! 位置情報の取得に失敗しました。")
	}
	
	// 方位情報取得時に呼ばれる
	func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
		//
	}
}
