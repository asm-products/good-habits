//
//  AppStoreReceipt.swift
//  Habits
//
//  Created by Michael Forrest on 30/08/2018.
//  Copyright © 2018 Good To Hear. All rights reserved.
//

import UIKit
import StoreKit
class AppStoreReceipt:NSObject, SKRequestDelegate {
    let refreshRequest = SKReceiptRefreshRequest()
    override init(){
        super.init()
        refreshRequest.delegate = self
        fetch()
    }
    func fetch(){
        guard let url = Bundle.main.appStoreReceiptURL else {
            return
        }
        if let reachability = try? url.checkResourceIsReachable(){
            if (reachability == false) {
                refreshRequest.start()
            }
        }else{
            print("Error checking receipt")
        }
    
    }
    func requestDidFinish(_ request: SKRequest) {
        
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
    }
}
