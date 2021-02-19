//
//  HabitsWidget.swift
//  HabitsWidget
//
//  Created by Michael Forrest on 14/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import HabitsCommon

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), habits: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        HabitsQueries.refresh()
        let habits = HabitsQueries.activeToday()
        let entry = SimpleEntry(date: Date(), habits: habits.map{ HabitProxy(with: $0)})
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        HabitsQueries.refresh()
        let habits = HabitsQueries.activeToday().map{ HabitProxy(with: $0) }
        var entries: [SimpleEntry] = []

        let times = [  Date() ]
            + habits.compactMap{ $0.reminderTimeToday }
        
        for entryDate in times {
            let entry = SimpleEntry(date: entryDate, habits: habits)
            entries.append(entry)
        }
        if let thisTimeTomorrow = Calendar.current.date(byAdding: DateComponents(day: 1), to: Date()) {
            let tomorrow = Calendar.current.startOfDay(for: thisTimeTomorrow)
            let habits = (HabitsQueries.active(on: tomorrow) as! [Habit])
                .map{ HabitProxy(with: $0) }
            let tomorrowEntry = SimpleEntry(date: tomorrow, habits: habits )
            entries.append(tomorrowEntry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


@main
struct HabitsWidget: Widget {
    let kind: String = "HabitsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Good Habits")
        .description("See your habits on your home screen")
    
    }
}

struct HabitsWidget_Previews: PreviewProvider {
    static var previews: some View {
        let habits = [
            HabitProxy(title: "Unchecked", color: .blue, state: nil, chainLength: -1),
            HabitProxy(title: "Checked", color: .green, state: .complete, chainLength: 30),
            HabitProxy(title: "Later", color: .orange, state: .none, chainLength: 15, reminderTime: DateComponents(hour: 19, minute: 55)),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Missed", color: .red, state: .broken, chainLength: 3),
        ]
        HabitsWidgetEntryView(entry: SimpleEntry(date: Date(), habits: habits))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        HabitsWidgetEntryView(entry: SimpleEntry(date: Date(), habits: habits.filter{$0.state == .complete}))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        HabitsWidgetEntryView(entry: SimpleEntry(date: Date(), habits: habits.filter{$0.state == .complete}))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        
        HabitsWidgetEntryView(entry: SimpleEntry(date: Date(), habits: habits.filter{ $0.reminderTimeToday != nil }))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        
        HabitsWidgetEntryView(entry: SimpleEntry(date: Date(), habits: habits.filter{ $0.reminderTimeToday != nil }))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        HabitsWidgetEntryView(entry: SimpleEntry(date: Date(), habits: habits))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        HabitsWidgetEntryView(entry: SimpleEntry(date: Date(), habits: habits))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
