//
//  AppFeatures+Observable.swift
//  HabitsCommon
//
//  Created by Michael Forrest on 14/01/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//
import UIKit
import SwiftUI
class AppFeaturesObserver: ObservableObject{
    @Published var statsEnabled: Bool = AppFeatures.statsEnabled()
    @Published var shouldShowReasonInput: Bool = AppFeatures.shouldShowReasonInput()
    
    init(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: APP_FEATURES_CHANGED), object: nil, queue: .main) {_ in
            self.update()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: STATS_PURCHASED), object: nil, queue: .main) {_ in
            self.update()
        }
    }
    func update(){
        statsEnabled = AppFeatures.statsEnabled()
        shouldShowReasonInput = AppFeatures.shouldShowReasonInput()
    }
}
