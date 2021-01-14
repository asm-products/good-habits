//
//  MainTabViewController.swift
//  Habits
//
//  Created by Michael Forrest on 29/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import UIKit
import SwiftUI
import HabitsCommon

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            addTrendsTab()
        }
    }

}
@available(iOS 14.0, *)
extension MainTabViewController{
    func addPurchaseTab(){
        let controller = StatsAndTrendsPurchaseInterface.createAlert()
        controller.tabBarItem = UITabBarItem(title: "Trends", image: UIImage(systemName: "calendar"), tag: 1)
        controller.tabBarItem.badgeValue = "🔒"
        viewControllers?.append(controller)
    }
    
    func addTrendsTab(){
        guard let moc = CoreDataClient.default()?.managedObjectContext else { return }
       
        let controller = UIHostingController(
            rootView: TrendsView()
                .environment(\.managedObjectContext, moc)
        )
        controller.tabBarItem = UITabBarItem(title: "Trends", image: UIImage(systemName: "calendar"), tag: 1)
        viewControllers?.append(controller)
    }

}
