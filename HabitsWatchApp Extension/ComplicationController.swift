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
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward]) // just show the daily counts
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date()) // start now
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().addingTimeInterval(60 * 60 * 36)) // 36 hours
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    func templateForFamily(_ family:CLKComplicationFamily, count: Int, progress:Float)->CLKComplicationTemplate?{
        let textProvider = CLKSimpleTextProvider(text: count == 0 ? "✓" : "\(count)")
        switch family{
        case .circularSmall:
            let result = CLKComplicationTemplateCircularSmallRingText()
            result.textProvider = textProvider
            result.fillFraction = progress
            return result
        case .modularSmall:
            let result = CLKComplicationTemplateModularSmallRingText()
            result.textProvider = textProvider
            result.fillFraction = progress
            return result
        case .utilitarianSmall:
            let result = CLKComplicationTemplateUtilitarianSmallRingText()
            result.textProvider = textProvider
            result.fillFraction = progress
            return result
        default:
            return nil
        }
    }
    func timelineEntry(_ complication:CLKComplication, date:Date, count:Int, progress:Float)->CLKComplicationTimelineEntry?{
        if let template = templateForFamily(complication.family, count: count, progress: progress){
            return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        }else{
            return nil
        }
    }
    // MARK: - Timeline Population
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        if let count = delegate.currentCount(){
            let total = delegate.todaysHabits?.count ?? 0
            let progress = Float(total - count.count) / Float(total)
            handler(timelineEntry(complication, date: count.date as Date, count: count.count, progress: progress))
        }else{
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
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
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        print("getTimelineEntriesForComplication after date \(date) call \(callsoCount)")
        callsoCount += 1
        handler(delegate.reminderCountsAfterDate(date, limit:limit).map { self.timelineEntry(complication, date: $0.date, count:$0.count, progress: $0.progress ?? 0)! } )
    }
    var delegate: ExtensionDelegate{
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    
    // MARK: - Update Scheduling
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        var components = DateComponents()
        components.day = 1

        let tomorrow = (Calendar.current as NSCalendar).date(byAdding: components, to: today() as Date, options: [])
        print("Will update habits \(tomorrow)")
        handler(tomorrow)
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler( templateForFamily(complication.family, count: 0, progress: 1) )
    }
    
}
