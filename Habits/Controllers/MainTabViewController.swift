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
let DonegoodRegisterButtonHasBeenPressedKey = "has-pressed-register-donegood"
let DonegoodRegisterButtonHasBeenPressedNotificationName = Notification.Name(DonegoodRegisterButtonHasBeenPressedKey)

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers?.first?.title = NSLocalizedString("Today", comment: "")
        if #available(iOS 14.0, *) {
            addTrendsTab()
            addDonegoodTab()
        }
    }

}
@available(iOS 14.0, *)
extension MainTabViewController{
    func addPurchaseTab(){
        let controller = StatsAndTrendsPurchaseInterface.createAlert()
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Trends", comment: ""), image: UIImage(systemName: "calendar"), tag: 1)
        controller.tabBarItem.badgeValue = "🔒"
        viewControllers?.append(controller)
    }
    
    func addTrendsTab(){
        guard let moc = CoreDataClient.default()?.managedObjectContext else { return }
       
        let controller = UIHostingController(
            rootView: TrendsView()
                .environment(\.managedObjectContext, moc)
        )
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Trends", comment: ""), image: UIImage(systemName: "calendar"), tag: 1)
        viewControllers?.append(controller)
    }

    func addDonegoodTab(){
        let controller = UIHostingController(rootView: DonegoodPromoTab() )
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Donegood", comment: ""), image: UIImage(systemName: "checkmark.square"), tag: 2)
        if UserDefaults.standard.bool(forKey: DonegoodRegisterButtonHasBeenPressedKey) != true{
            controller.tabBarItem.badgeValue = "?"
        }
        NotificationCenter.default.addObserver(forName: DonegoodRegisterButtonHasBeenPressedNotificationName, object: nil, queue: nil) { _ in
            controller.tabBarItem.badgeValue = nil
        }
        
        viewControllers?.append(controller)
    }
}
