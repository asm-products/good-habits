//
//  HabitAnalysis.m
//  Habits
//
//  Created by Michael Forrest on 15/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitAnalysis.h"
#import "TimeHelper.h"
#import "DayKeys.h"
@implementation HabitAnalysis
-(instancetype)initWithHabit:(Habit *)habit{
    if(self = [super init]){
        self.habit = habit;
    }
    return self;
}
-(BOOL)hasUnauditedChainBreaks{
    return [self nextUnauditedDay] != nil;
}
-(HabitDay *)nextUnauditedDay{
    NSInteger index = [self.habit.habitDays indexOfObjectPassingTest:^BOOL(HabitDay*habitDay, NSUInteger idx, BOOL *stop) {
        return [habitDay.chainBreakStatus isEqualToString:@"fresh"];
    }];
    return index == NSNotFound ? nil : self.habit.habitDays[index];
}
@end
