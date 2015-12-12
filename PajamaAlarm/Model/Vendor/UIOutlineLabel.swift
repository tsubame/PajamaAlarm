//
//  UIOutlineLabel.swift
//  EarClerics
//
//  Created by hideki on 2014/11/21.
//  Copyright (c) 2014年 Tsubaki. All rights reserved.
//

import Foundation
import UIKit

class UIOutlineLabel: UILabel {
    
    var outlineColor = UIColor.blackColor()
    var outlineSize: CGFloat = 2.0;
    
    // 初期化
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
	
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.userInteractionEnabled = true
    }
    
    
    override func drawTextInRect(rect: CGRect) {
        var cr = UIGraphicsGetCurrentContext()
        let textColor = self.textColor
    
		CGContextSetLineWidth(cr, outlineSize)
		CGContextSetLineJoin(cr, CGLineJoin.Round)
		CGContextSetTextDrawingMode(cr, CGTextDrawingMode.Stroke)
		
		self.textColor = outlineColor
		super.drawTextInRect(rect)
		CGContextSetTextDrawingMode(cr, CGTextDrawingMode.Fill)
		self.textColor = textColor
		
        super.drawTextInRect(rect)
    }

}