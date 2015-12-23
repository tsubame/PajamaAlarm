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
	
	//@IBOutlet weak var _label: UIOutlineLabel!
	@IBOutlet weak var _label: FadeLabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		//_label.show("こんにちは〜。\nhello!! あのー……どうされたんですか？\n今一つですね。")

		_label.text = "（。・ω・）ノ゛ こんばんわー。\nこんにちは〜。うっひゃー！ hello!!"
		_label.showWithFade()
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
