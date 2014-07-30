//
//  HabitAnalysis.h
//  Habits
//
//  Created by Michael Forrest on 15/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Habit.h"
#import "HabitDay.h"
@interface HabitAnalysis : NSObject
-(instancetype)initWithHabit:(Habit*)habit;
@property (nonatomic, strong) Habit* habit;
-(BOOL)hasUnauditedChainBreaks;
-(HabitDay*)nextUnauditedDay;
@end
