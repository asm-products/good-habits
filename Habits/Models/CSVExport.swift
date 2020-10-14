//
//  CSVExport.swift
//  HabitsCommon
//
//  Created by Michael Forrest on 22/09/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import Foundation

@objc public class CSVExport: NSObject{
    override init(){
        
    }
    @objc public func execute()->String{
        // not sure we need a background thread so using default client
        guard let habits = HabitsQueries.fetchedResultsController(for: CoreDataClient.default())?.fetchedObjects as? [Habit]
        else { return ""}
        var rows:[String] = []
        rows.append(
            (["Date"] + habits.map{$0.title}).joined(separator: "\t")
        )
        
        var date = habits.compactMap{$0.earliestDate()}.reduce(Date(), min)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        while date <= Date() {
            let values:[String] = [
                formatter.string(from: date),
            ] + habits.map{ habit in
                
                if let dayState = habit.chain(for: date)?.habitDay(for: date)?.dayState(){
                    switch(dayState){
                    case .firstInChain, .lastInChain,.midChain, .alone:
                        return "TRUE"
                    case .notRequired: return "N/A"
                    default: return "FALSE"
                    }
                }else{
                    return ""
                }
            }
            rows.append(values.joined(separator: "\t"))
            date = calendar.date(byAdding: DateComponents(day:1), to: date)!
        }
        return rows.joined(separator: "\n")
    }
}
