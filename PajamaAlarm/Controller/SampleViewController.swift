//
//  SampleViewController.swift
//  PajamaAlarm
//
//  Created by hideki on 2015/12/10.
//  Copyright © 2015年 Tsubaki. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {

	//@IBOutlet weak var _fadeLabel: FadeLabel!
	
	@IBOutlet weak var _label: UIOutlineLabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		_label.outlineColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
		_label.outlineSize = 5.0
		//_label.shadowColor = UIColor.grayColor()
		_label.text = "こんにちは〜"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		//_fadeLabel.showTextWithFade("こんにちは〜。\nhello!! あのー……どうされたんですか？\n今一つですね。")

		//_label.shadowColor = UIColor.grayColor()
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
