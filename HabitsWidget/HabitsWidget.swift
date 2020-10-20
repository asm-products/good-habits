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
        let habits = HabitsQueries.activeToday() as! [Habit]
        let entry = SimpleEntry(date: Date(), habits: habits.map{ HabitProxy(with: $0)})
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        HabitsQueries.refresh()
        let habits = (HabitsQueries.activeToday() as! [Habit]).map{ HabitProxy(with: $0) }
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            // TODO: Make this the whole day and reveal habits based on their scheduled time
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, habits: habits)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let habits: [HabitProxy]
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
        let entry = SimpleEntry(date: Date(), habits: [
            HabitProxy(title: "Unchecked", color: .blue, state: nil, chainLength: -1),
            HabitProxy(title: "Checked", color: .green, state: .complete, chainLength: 30),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Other Checked", color: .orange, state: .complete, chainLength: 15),
            HabitProxy(title: "Missed", color: .red, state: .broken, chainLength: 3),
        ])
        HabitsWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        HabitsWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        HabitsWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
