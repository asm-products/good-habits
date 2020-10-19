//
//  Widgets.swift
//  Habits
//
//  Created by Michael Forrest on 18/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import UIKit
import WidgetKit
@available(iOS 14.0, *)
public class Widgets: NSObject {
    @objc public static func reload(){
        WidgetCenter.shared.reloadAllTimelines()
    }
}
