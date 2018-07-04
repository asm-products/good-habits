//
//  HabitToggler.h
//  Habits
//
//  Created by Michael Forrest on 11/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Habit.h"
@class Habit;
#import "Failure.h"
#import "Chain.h"

#define TODAY_CHECKED_FOR_CHAIN @"TODAY_CHECKED_FOR_CHAIN"
#define CHAIN_MODIFIED @"CHAIN_MODIFIED"
#define HABIT_TOGGLE_COMPLETE @"HABIT_TOGGLE_COMPLETE"

@interface HabitToggler : NSObject
@property (nonatomic,strong, nullable) Failure * failure;
@property (nonatomic) BOOL shouldNotify;
-(instancetype __nonnull)initWithNotifications:(BOOL)shouldNotify;
NS_ASSUME_NONNULL_BEGIN
-(DayCheckedState)toggleTodayForHabit:(Habit*)habit;
/// Toggles day state and also assigns self.failure if there is one
-(DayCheckedState)toggleHabit:(Habit*)habit day:(NSDate*) day;
NS_ASSUME_NONNULL_END
@end
