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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        showHabitsListIfAvailableAnimated(false)
        NotificationCenter.default.addObserver(self, selector: #selector(WatchLandingInterfaceController.updated), name: NSNotification.Name(rawValue: UpdateNotificationName), object: nil)
    }
    @objc func updated(){
        showHabitsListIfAvailableAnimated(true)
    }
    func showHabitsListIfAvailableAnimated(_ animated:Bool){
        if delegate.todaysHabits != nil {
            popToRootController()
            NotificationCenter.default.removeObserver(self)
        }
    }
    var delegate: ExtensionDelegate{
        return WKExtension.shared().delegate as! ExtensionDelegate
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
