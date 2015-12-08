//
//  AlarmTimePickersUIView.swift
//
//  Created by hideki on 2015/11/12.
//
//　アラームセット画面のピッカービュー2つを内包するView
//
//	（依存クラス）
//		Constants.swift
//
//  （使い方）
//		view = AlarmTimePickersUIView(frame: CGRectMake(0, 0, 300, 300))
//		parentView.addSubview(view)
//

import UIKit

class AlarmTimePickersUIView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
	
	// 定数
	let VIEW_BG_COLOR              = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
	let PICKER_BORDER_COLOR        = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.2).CGColor
	let PICKER_LABEL_TEXT_COLOR    = UIColorFromRGB(0x5f352f)
	let PICKER_LOOP_COUNT          = 30						// ピッカーのアイテムのループ回数 偶数を指定
	let PICKER_LABEL_FONT          = "Avenir"				// ピッカーのフォント
	let TIME_FLAGS: NSCalendarUnit = [.Year, .Month,		// 時刻処理用のフラグ
									  .Day, .Hour, .Minute]
	
	// プライベート変数
	var _hPicker: UIPickerView!				// ピッカー（時間）
	var _mPicker: UIPickerView!				// ピッカー（分）
	var _hItems = [String]()				// ピッカー（時間）に表示する項目
	var _mItems = [String]()				// ピッカー（分）に表示する項目
	var _hIndex = 0							// ピッカー（時間）の選択インデックス
	var _mIndex = 0							// ピッカー（分）の選択インデックス
	
	var _pickerHeight   : CGFloat = 200		// ピッカーの高さ
	var _pickerWidth    : CGFloat = 120		// ピッカーの幅
	var _pickerRowHeight: CGFloat = 100		// ピッカーの行の高さ
	var _pickerFontSize : CGFloat = 100		// ピッカーの文字サイズ
	
	var _alarmTime: NSDate?					// アラームのセット時刻
	
	
	// 描画時に呼ばれる
	override func drawRect(rect: CGRect) {
		makeAll()
	}
	
	// ピッカーに設定されたアラーム時刻を返す
	func getAlarmTime() ->NSDate? {
		setAlarmTimeFromPicker()
		
		return _alarmTime
	}
	
	//======================================================
	// ピッカーの生成
	//======================================================
	
	// 部品、ピッカーの生成
	func makeAll() {
		self.backgroundColor = VIEW_BG_COLOR
		
		// ピッカー生成
		setPickerSizeFromScreen()
		makePickerItems()
		makePickerViews()
		
		// ピッカーのインデックスを適切な位置に移動
		movePickerIndex()
	}
	
	// ピッカーの高さ、文字サイズを画面サイズに比例して変更
	func setPickerSizeFromScreen() {
		_pickerRowHeight = CGFloat(UIScreen.mainScreen().bounds.width / 4)
		_pickerFontSize  = _pickerRowHeight * 0.8
		//_pickerWidth     = _pickerRowHeight
	}
	
	// ピッカービュー2つを生成
	func makePickerViews() {
		_hPicker = makePickerView(CGRectMake(0, 0, _pickerWidth, _pickerHeight))
		_mPicker = makePickerView(CGRectMake(_pickerWidth + 15, 0, _pickerWidth, _pickerHeight))
		
		self.addSubview(_hPicker)
		self.addSubview(_mPicker)
	}
	
	// 単一のピッカービュー生成
	func makePickerView(frame: CGRect) -> UIPickerView {
		let p = UIPickerView(frame: frame)

		p.delegate   = self
		p.dataSource = self
		p.showsSelectionIndicator = true
		p.layer.borderColor       = PICKER_BORDER_COLOR // 枠線
		p.layer.borderWidth       = 1					// 枠線の幅
		
		return p
	}
	
	// ピッカービューに表示する項目を生成
	func makePickerItems() {
		// 時刻 0〜23 × 数ループ分
		for _ in 0..<PICKER_LOOP_COUNT {
			for h in 0...23 {
				let str = NSString(format: "%02d", h)
				_hItems.append(str as String)
			}
		}
		
		// 分 0〜59を数分刻みに × 数ループ分
		for _ in 0..<PICKER_LOOP_COUNT {
			for var m = 0; m < 60; m += SET_ALARM_MINUTE_INTERVAL {
				let minStr = NSString(format: "%02d", m)
				
				_mItems.append(minStr as String)
			}
		}
	}
	
	//======================================================
	// ピッカーの操作
	//======================================================
	
	// ピッカービューの中央付近の0:00を選択
	func selectCenterOfPicker() {
		_hIndex = _hItems.count / 2
		_mIndex = _mItems.count / 2
		
		_hPicker.selectRow(_hIndex, inComponent: 0, animated: false)
		_mPicker.selectRow(_mIndex, inComponent: 0, animated: false)
	}
	
	// ピッカーの値を_alarmTimeにセット　時、分以外は適当な値
	func setAlarmTimeFromPicker() {
		let comps    = CALENDAR.components(TIME_FLAGS, fromDate: NSDate())
		comps.hour   = Int(_hItems[_hIndex])!
		comps.minute = Int(_mItems[_mIndex])!
		
		_alarmTime = CALENDAR.dateFromComponents(comps)

		// 現在時刻より前なら明日の日付に変更
		let res = CALENDAR.compareDate(_alarmTime!, toDate: NSDate(), toUnitGranularity: .Minute)
		if res == NSComparisonResult.OrderedAscending {
			_alarmTime = NSDate(timeInterval: 86400, sinceDate: _alarmTime!)
		}
	}
	
	// アラーム時刻をピッカービューの選択項目に反映
	func setAlarmTimeToPicker() {
		_alarmTime = readPref(PREF_KEY_ALARM_TIME) as? NSDate
		if _alarmTime == nil {
			return
		}

		let comps  = CALENDAR.components(TIME_FLAGS, fromDate: _alarmTime!)
		let hour   = comps.hour
		let minute = comps.minute
		
		// デフォルトで0時が選択されているのでインデックス、ピッカーの値を変更
		_hIndex += hour
		_mIndex += minute / SET_ALARM_MINUTE_INTERVAL
		
		_hPicker.selectRow(_hIndex, inComponent: 0, animated: false)
		_mPicker.selectRow(_mIndex, inComponent: 0, animated: false)
	}
	
	func movePickerIndex() {
		selectCenterOfPicker()
		setAlarmTimeToPicker()
	}
	
	//===========================================================
	// UIPickerViewDelegate
	//===========================================================
	
	
	//　行の高さ　可変にすべき
	func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return CGFloat(_pickerRowHeight)
	}
	
	// ピッカーの各セルの生成
	func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
		
		let cell  = UIView (frame: CGRectMake(0, 0, _pickerWidth, _pickerRowHeight))
		let label = UILabel(frame: CGRectMake(0, 0, _pickerWidth, _pickerRowHeight))
		
		label.font          = UIFont(name: PICKER_LABEL_FONT, size: _pickerRowHeight * 0.8)
		label.textAlignment = NSTextAlignment.Center
		label.textColor     = PICKER_LABEL_TEXT_COLOR
		
		if pickerView == _hPicker {
			label.text = _hItems[row]
		} else {
			label.text = _mItems[row]
		}
		cell.addSubview(label)
		
		return cell
	}
	
	// ピッカーが選択された時の処理 インデックスに代入
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == _hPicker {
			_hIndex = row
		} else {
			_mIndex  = row
		}
	}
	
	//===========================================================
	// UIPickerViewDataSource
	//===========================================================
	
	// データ数
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var count = 0
		
		if pickerView == _hPicker {
			count = _hItems.count
		} else {
			count = _mItems.count
		}
		
		return count
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	
}
