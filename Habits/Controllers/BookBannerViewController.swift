//
//  BookBannerViewController.swift
//  Habits
//
//  Created by Michael Forrest on 24/04/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import UIKit
let BookPromoStatusUpdated = NSNotification.Name("BOOK_PROMO_STATUS_UPDATED")
public let BookPitchSnoozedUntilKey = "book-pitch-snoozed-until"
class BookBannerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func snooze(for components: DateComponents){
        let date = Calendar.current.date(byAdding: components, to: Date())!
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: BookPitchSnoozedUntilKey)
        NotificationCenter.default.post(name: BookPromoStatusUpdated, object: nil)
    }
    
    @IBAction func didPressCloseButton(_ sender: Any) {
        // CONFIRM or SNOOZE
        let activity = UIAlertController(title: "Remove this message?", message: nil, preferredStyle: .actionSheet)
        
        activity.addAction ( UIAlertAction(title: "Ask me again in a week", style:.default, handler: { _ in
            self.snooze(for: DateComponents(day: 7))
           
        }))
        activity.addAction ( UIAlertAction(title: "Ask me again in a month", style:.default, handler: { _ in
            self.snooze(for: DateComponents(month: 1))
        }))
        activity.addAction(.init(title: "Never ask again", style: .destructive, handler: { _ in
            self.snooze(for: DateComponents(year: 100))
        }))
        activity.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
        }))
        present(activity, animated: true, completion: nil)
    }
    
    
}
