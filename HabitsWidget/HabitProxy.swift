//
//  HabitProxy.swift
//  Habits
//
//  Created by Michael Forrest on 18/10/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

import Foundation
import HabitsCommon
import SwiftUI

class HabitProxy: NSObject, ObservableObject, Identifiable{
    let id: String
    let title: String
    let color: Color
    @Published var state: DayCheckedState?
    let chainLength: Int?
    let habit: Habit?
    init(with habit: Habit){
        self.id = habit.identifier
        self.title = habit.title
        self.color = Color(habit.color)
        self.state = habit.currentChain()?.dayState() ?? .broken
        self.chainLength = habit.currentChain()?.currentChainLengthForDisplay()
        self.habit = habit
    }
    init(title: String, color: Color, state: DayCheckedState?, chainLength: Int){
        self.id = UUID().uuidString
        self.title = title
        self.color = color
        self.state = state
        self.chainLength = chainLength
        self.habit = nil
    }
    
    func toggle(){
        guard let habit = habit else { return } // testing probably
        let toggler = HabitToggler()
        state = toggler.toggleToday(for: habit)
    }
}
