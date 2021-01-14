//
//  SelectedMonth.swift
//  Habits
//
//  Created by Michael Forrest on 08/01/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

import SwiftUI
import HabitsCommon

private let OneDay = DateComponents(day: 1)

struct ScoreRow: Identifiable{
    var id: String{
        habit.identifier
    }
    let habit: Habit
    var daysChecked: Int = 0
    var successRate: Float = 0
    var chainBreaks: Int?
    var daysRequired: Int = 0
    
    init(habit: Habit, selectedMonth: DateComponents){
        self.habit = habit
        var components = selectedMonth
        components.day = 1
        
        var total = 0
        var includedChains = Set<Chain>()
        let habitStartedDate = habit.earliestDate() ?? Date()
        let calendar = TimeHelper.utcCalendar()!
        let today = TimeHelper.today()
        let endDate = habit.isActive.boolValue ? today : habit.currentChain()?.lastDateCache ?? today
        
        
        while components.month == selectedMonth.month{
            guard var date = calendar.date(from: components) else { break }
            
            if date >= habitStartedDate && date <= endDate && habit.isRequired(onWeekday: date){
                daysRequired += 1
                
                let chain = habit.chain(for: date)
                if let chain = chain {
                    includedChains.insert(chain)
                }
                total += chain?.overlapsDate(date) == true ? 1 : 0
            }
            
            date = calendar.date(byAdding: DateComponents(day: 1), to: date)!
            components = calendar.dateComponents([.year,.month,.day], from: date)
            
        }
        
        daysChecked = total // not right because it doesn't take into account skippable days
        if daysRequired > 0{
            successRate = Float(total) / Float(daysRequired)
        }
        chainBreaks = includedChains.count > 1 ? includedChains.count - 1 : nil
    }
}

struct ScoreForMonth{
    var overall: String
    var rows: [ScoreRow]
    
    init(habits: FetchedResults<Habit>, selectedMonth: DateComponents){
        rows = habits.map{ habit in
            ScoreRow(habit: habit, selectedMonth: selectedMonth)
        }.sorted(by: { (a, b) -> Bool in
            a.successRate > b.successRate
        })
        let totalDaysRequired = rows.map{$0.daysRequired}.reduce(0,+)
        let totalDays = rows.map{$0.daysChecked}.reduce(0,+)
        let score = totalDaysRequired > 0 ? Float(totalDays) / Float(totalDaysRequired) : 0
        overall = "\(Int(score * 100))%"
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

@available(iOS 14.0, *)
struct SelectedMonth: View {
    @Namespace private var successRateBar
    @Namespace private var rowPosition
    var habits: FetchedResults<Habit>
    var selectedMonth:  DateComponents
    var body: some View {
        let score = ScoreForMonth(habits: habits, selectedMonth: selectedMonth)
        return VStack{
            Text("\(Calendar.current.shortMonthSymbols[selectedMonth.month! - 1]) \(String(selectedMonth.year ?? 0))").font(.headline)
            
            Text(score.overall).font(.largeTitle).bold()
            Text("SUCCESS").bold()//.foregroundColor(Color(Colors.grey()))
            
            ScrollView{
                ForEach(score.rows){ row in
                    VStack(alignment: .leading){
                        HStack{
                            Text(row.habit.title).frame(width: 100, alignment: .leading).lineLimit(1)
                            HStack{
                                Image(systemName: "checkmark")
                                Text("\(row.daysChecked)").fixedSize()
                                Divider().background(Color.white)
                                Text("\(Int(row.successRate * 100))%").lineLimit(1).fixedSize()
                                Spacer()
                            }
                            .padding(.horizontal,10)
                            .foregroundColor(.white)
                            .frame(width: 100 + CGFloat(row.successRate) * 100)
                            .background(Color(row.habit.color))
                            .cornerRadius(20)
                            .matchedGeometryEffect(id: row.habit.identifier, in: successRateBar)
                            
                            if let chainBreaks = row.chainBreaks{
                                HStack{
//                                    Image("chain-break")
                                    Text("! \(chainBreaks)")
                                }.foregroundColor(Color(Colors.red()))
                            }
                            Spacer()
                        }
                        .matchedGeometryEffect(id: row.habit.identifier, in: rowPosition)
                    }
                    .font(.system(size: 14, weight: .bold, design: .default))
                }
            }
        }.padding()
        .background(Color(UIColor.systemBackground))
        
        .cornerRadius(13)
    }
}

@available(iOS 14.0, *)
struct SelectedMonth_Previews: PreviewProvider {
    static var previews: some View {
        TrendsView_Previews.previews
    }
}
