//
//  ComplicationController.swift
//  VanillaWatchKitApp WatchKit Extension
//
//  Created by Michael Forrest on 21/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

import ClockKit
import WatchKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward]) // just show the daily counts
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(NSDate()) // start now
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(NSDate().dateByAddingTimeInterval(60 * 60 * 36)) // 36 hours
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    func templateForFamily(family:CLKComplicationFamily, count: Int, progress:Float)->CLKComplicationTemplate?{
        let textProvider = CLKSimpleTextProvider(text: count == 0 ? "✓" : "\(count)")
        switch family{
        case .CircularSmall:
            let result = CLKComplicationTemplateCircularSmallRingText()
            result.textProvider = textProvider
            result.fillFraction = progress
            return result
        case .ModularSmall:
            let result = CLKComplicationTemplateModularSmallRingText()
            result.textProvider = textProvider
            result.fillFraction = progress
            return result
        case .UtilitarianSmall:
            let result = CLKComplicationTemplateUtilitarianSmallRingText()
            result.textProvider = textProvider
            result.fillFraction = progress
            return result
        default:
            return nil
        }
    }
    func timelineEntry(complication:CLKComplication, date:NSDate, count:Int, progress:Float)->CLKComplicationTimelineEntry?{
        if let template = templateForFamily(complication.family, count: count, progress: progress){
            return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        }else{
            return nil
        }
    }
    // MARK: - Timeline Population
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        if let count = delegate.currentCount(){
            let total = delegate.todaysHabits?.count ?? 0
            let progress = Float(total - count.count) / Float(total)
            handler(timelineEntry(complication, date: count.date, count: count.count, progress: progress))
        }else{
            handler(nil)
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        handler(nil)
    }
    func requestedUpdateDidBegin() {
        print("update did begin")
        delegate.populateTodayFromApplicationContext()
    }
    func requestedUpdateBudgetExhausted() {
        print("no budget!")
    }
    var callsoCount = 0
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        print("getTimelineEntriesForComplication after date \(date) call \(callsoCount)")
        callsoCount += 1
        handler(delegate.reminderCountsAfterDate(date, limit:limit).map { self.timelineEntry(complication, date: $0.date, count:$0.count, progress: $0.progress ?? 0)! } )
    }
    var delegate: ExtensionDelegate{
        return WKExtension.sharedExtension().delegate as! ExtensionDelegate
    }
    
    // MARK: - Update Scheduling
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        let components = NSDateComponents()
        components.day = 1

        let tomorrow = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: today(), options: [])
        print("Will update habits \(tomorrow)")
        handler(tomorrow)
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler( templateForFamily(complication.family, count: 0, progress: 1) )
    }
    
}
