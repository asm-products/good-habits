//
//  HabitsWidgetEntryView.swift
//  Habits
//
//  Created by Michael Forrest on 18/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import SwiftUI
import HabitsCommon
import WidgetKit

func LocalizedString(_ key: String)->String{
    Bundle(identifier: "goodtohear.HabitsCommon")?.localizedString(forKey: key, value: "", table: nil) ?? key
}

struct WidgetHeader: View {
    var entry: Provider.Entry
    
    var body: some View{
        HStack{
            Image(systemName: entry.imageName)
            
            Text("\(entry.completedHabits)")
            Divider().background(Color.white).environment(\.colorScheme, .light)
            Text("\(entry.totalHabits)").opacity(0.6)
        }
        .padding(.horizontal, 10)
        .overlay(Capsule().stroke().opacity(0.8))
        .font(.system(size: 14, weight: .bold, design: .default))
        .frame(maxWidth: .infinity)
        .frame(height: 20)
        .padding(6)
        .background(Color(Colors.green()))
        .foregroundColor(.white)
    }
}

struct HabitsList: View {
    let columns = [GridItem(.flexible())]
    var habits: [HabitProxy]
    var size:HabitCell.Size = .normal
    @Environment(\.widgetFamily) var widgetFamily
    var body: some View{
        let canShowCount = widgetFamily == .systemLarge ? 8 : 3
        let completed = habits.filter{ $0.state == .complete}
        
        let shouldRemoveCompleted = canShowCount < habits.count && completed.count > 0
        var visibleHabits = shouldRemoveCompleted ? habits.filter{ $0.state != .complete} : habits
        if visibleHabits.count < canShowCount && shouldRemoveCompleted && completed.count > 0{
            let countToAdd = min(canShowCount - visibleHabits.count, completed.count)
            visibleHabits.insert(contentsOf: completed.suffix(countToAdd), at: 0)
        }
        return LazyVGrid(columns: columns, spacing: 6.0){
            ForEach(visibleHabits.prefix(canShowCount)){ habit in
                HabitCell(habit: habit, size: size)
                Divider()
            }
            .padding(.horizontal)
        }
    }
}

struct HabitsWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        VStack {
            WidgetHeader(entry: entry)
            if entry.allDoneSoFar {
                HStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 10) {
                        if entry.completedHabits > 0 {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Color(Colors.green()))
                        }
                        if entry.habitsNeededLater.count > 0{
                            (
                                Text("\( entry.completedHabits > 0 ? "+" : "")\(entry.habitsNeededLater.count) ")
                                    + Text(LocalizedString("Later").uppercased())
                            )
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .opacity(0.5)
                        }
                    }
                    .frame(minWidth: 140, maxHeight: .infinity)
                    
                    if widgetFamily != .systemSmall && entry.habitsNeededLater.count > 0 {
                        Divider()
                        VStack {
                            HabitsList(habits: entry.habitsNeededLater, size: .smallWithTime)
                                .frame(maxWidth: .infinity)
                        }.clipped()
                    }
                }
            }else{
                HabitsList(habits: entry.habits, size: widgetFamily == .systemSmall ? .small : .normal)
            }
            Spacer()
        }.clipped().background(Color(UIColor.systemBackground))
        
    }
}

struct HabitsWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        HabitsWidget_Previews.previews
            .environment(\.colorScheme, .dark)
    }
}
