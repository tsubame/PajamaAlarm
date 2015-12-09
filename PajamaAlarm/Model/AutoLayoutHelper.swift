//
//  AutoLayoutHelper.swift
//  Komoriuta
//
//  Created by hideki on 2015/05/20.
//
//

import Foundation
import UIKit

class AutoLayoutHelper {
	
	
	// オートレイアウト サイズ調整 addSubview()後に実行
	func addAutoLayoutSizing(item: UIView, toItem: UIView, wRatio: CGFloat? = nil, hRatio: CGFloat? = nil) {
		
		// Swift 2.0
		item.translatesAutoresizingMaskIntoConstraints = false
		
		// Swift 1.2
		//item.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		var consts = [NSLayoutConstraint]()
		
		if wRatio != nil {
			let cst = NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: toItem, attribute: .Width, multiplier: wRatio! / 1.0, constant: 0.0)
			consts.append(cst)
		}
		if hRatio != nil {
			let cst = NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: toItem, attribute: .Height, multiplier: hRatio! / 1.0, constant: 0.0)
			consts.append(cst)
		}
		
		//self.view.addConstraints(consts)
		toItem.addConstraints(consts)
	}
	
	// オートレイアウト センタリング addSubview()後に実行
	func addAutoLayoutCentering(item: UIView, toItem: UIView, centerX: Bool = true, centerY: Bool = true) {
		// Swift 2.0
		item.translatesAutoresizingMaskIntoConstraints = false
		
		//item.setTranslatesAutoresizingMaskIntoConstraints(false)
		var consts = [NSLayoutConstraint]()
		
		// X座標の中央寄せ
		if centerX == true {
			let cst = NSLayoutConstraint(item: item, attribute: .CenterX, relatedBy: .Equal, toItem: toItem, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
			consts.append(cst)
		} else {
			let cst = NSLayoutConstraint(item: item, attribute: .Left, relatedBy: .Equal, toItem: toItem, attribute: .Left, multiplier: 1, constant: item.frame.origin.x)
			consts.append(cst)
		}
		
		// Y座標の中央寄せ
		if centerY == true {
			let cst = NSLayoutConstraint(item: item, attribute: .CenterY, relatedBy: .Equal, toItem: toItem, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
			consts.append(cst)
		} else {
			let cst = NSLayoutConstraint(item: item, attribute: .Top, relatedBy: .Equal, toItem: toItem, attribute: .Top, multiplier: 1, constant: item.frame.origin.y)
			consts.append(cst)
		}
		
		//self.view.addConstraints(consts)
		toItem.addConstraints(consts)
	}
}
