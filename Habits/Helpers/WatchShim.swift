//
//  WatchShim.swift
//  Habits
//
//  Created by Michael Forrest on 21/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import UIKit

class WatchShim: NSObject {
    private var watchConnectionHelper:AnyObject?
    override init(){
        super.init()
        
        if #available(iOS 9.0, *) {
            self.watchConnectionHelper = WatchConnectionHelper()
        } else {
            // Fallback on earlier versions
        }
    }
    class func handleWatchkitExtensionRequest(userInfo:NSDictionary?, reply:(reply:NSDictionary?)->Void){
    }
}
