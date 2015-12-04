//
//  WatchLandingInterfaceController.swift
//  Habits
//
//  Created by Michael Forrest on 28/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import WatchKit
import Foundation


class WatchLandingInterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        showHabitsListIfAvailableAnimated(false)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updated", name: UpdateNotificationName, object: nil)
    }
    func updated(){
        showHabitsListIfAvailableAnimated(true)
    }
    func showHabitsListIfAvailableAnimated(animated:Bool){
        if delegate.todaysHabits != nil {
            popToRootController()
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    var delegate: ExtensionDelegate{
        return WKExtension.sharedExtension().delegate as! ExtensionDelegate
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
