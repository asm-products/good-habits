//
//  HabitCell.swift
//  Habits
//
//  Created by Michael Forrest on 18/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import SwiftUI
import HabitsCommon

struct HabitCell: View{
    @ObservedObject var habit:HabitProxy
    var size: Size
    
    enum Size{
        case small
        case normal
        case smallWithTime
    }
    
    var checkboxMark: Image?{
        switch habit.state{
        case .complete: return Image(systemName: "checkmark")
        case .broken: return Image(systemName: "xmark")
        default: return nil
        }
    }
    
    var body: some View{
        let fontSize:CGFloat = size != .normal ? 12 : 18
        return HStack(spacing: 0){
            Link(destination: URL(string: "goodhabits://toggle/\(habit.id)")!, label: {
                Rectangle()
                     .fill(habit.color)
                     .frame(width: 24, height: 24)
                     .overlay(
                         checkboxMark
                             .foregroundColor(.white)
                             .font(.system(size: 20, weight: .bold, design: .default))
                         , alignment: .center)
                 .padding(.trailing, fontSize * 0.5)
            })
          
               
            Text(habit.title)
                .font(.system(size: fontSize, weight: .bold, design: .default))
                .frame(maxHeight: size != .normal ? 10 : 20)
                
            
            Spacer()
            if size != .small{
                if let time = habit.reminderTimeToday{
                    Text(DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .short))
                        .font(.caption)
                        .padding(.trailing)
                }
            }
            if size != .smallWithTime {
                Circle()
                    .fill((habit.chainLength ?? 0) < 0 ? Color.gray : habit.color)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text("\(habit.chainLength ?? 0)")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold, design: .default))
                    )
            }
        }
    }
}

struct HabitCell_Previews: PreviewProvider {
    static var previews: some View {
        HabitsWidget_Previews.previews.environment(\.colorScheme, .dark)
    }
}
