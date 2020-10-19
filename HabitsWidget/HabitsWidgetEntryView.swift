//
//  HabitsWidgetEntryView.swift
//  Habits
//
//  Created by Michael Forrest on 18/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import SwiftUI
import HabitsCommon

struct HabitsWidgetEntryView : View {
    let columns = [GridItem(.flexible())]
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 6.5){
            Text("GOOD HABITS")
                .font(.system(size: 14, weight: .bold, design: .default))
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(Color(Colors.green()))
                //                .cornerRadius(14)
                .foregroundColor(.white)
            ForEach(entry.habits.prefix(widgetFamily == .systemLarge ? 8 : 3)){ habit in
                HabitCell(habit: habit)
                Divider()
            }
            .padding(.horizontal)
        }
            Spacer()
        }
        
    }
}

struct HabitsWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        HabitsWidget_Previews.previews
    }
}
