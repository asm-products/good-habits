//
//  HabitCell.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitCell.h"
#import "CheckBox.h"
#import "Colors.h"
#import "HabitsQueries.h"
#import "CountView.h"
#import "Habit.h"
@implementation HabitCell{
    __weak IBOutlet CountView *countView;
}
-(void)build{
    [super build];
    //  y = 8 because the check box starts at 10. yes. not ideal.
    countView.text = @[@0, @0];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCheckboxTapped)];
    [self.checkbox addGestureRecognizer:tap];
}
-(void)onCheckboxTapped{
    DayCheckedState state = [self.chain stepToNextStateForDate: self.now];
    [self setState:state];
}

-(UIColor*)labelTextColor{
    return [UIColor blackColor];
    // TODO: make the due habits red again
//    return (([self.habit due:self.now] && ![self.habit done:(self.now)]) || (!self.inactive && self.habit.currentChainLength == 0)) ? [Colors red] : [UIColor blackColor];
}
//-(void)setHabit:(Habit *)habit{
-(void)setState:(DayCheckedState)state{
    _state = state;
    self.label.alpha = self.inactive ? 0.5 : 1.0;
    self.checkbox.state = state;
    self.checkbox.label = self.chain.habit.title;
    self.label.text =// [NSString stringWithFormat:@"%@ %@",habit.identifier,habit.title];//
        self.chain.habit.title;
    self.label.textColor = [self labelTextColor];
    
    NSInteger countOfDaysOverdue = self.chain.countOfDaysOverdue;
    NSLog(@"Count of days overdue for %@ = %@ (next due date %@)", self.chain.habit.title, @(countOfDaysOverdue), self.chain.nextRequiredDate);
    NSInteger currentChainLength = countOfDaysOverdue > 0 ? -countOfDaysOverdue : self.chain.length;
    NSInteger longestChain = self.chain.habit.longestChain.length;
    countView.color = self.chain.habit.color;
    countView.text = @[ @(currentChainLength), @(longestChain) ];
    countView.isHappy = currentChainLength > 0 && currentChainLength == longestChain;
    countView.highlighted = false;
}
-(void)update{
    [self setState:self.state];
}
@end
