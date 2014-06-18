//
//  CalendarViewController.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"

@protocol CalendarNavigation <NSObject>
-(void)forward;
-(void)backward;
@end

@interface CalendarViewController : UIViewController
@property (nonatomic, strong) Habit * habit;
-(void)showChainsForHabit:(Habit*)habit;
-(NSDate*)dayInPreviousMonth;
-(NSDate*)dayInNextMonth;
-(void)showMonthIncludingTime:(NSDate*)time;
@property (nonatomic, strong) NSDate * dateToShow;
@property (nonatomic, weak) id<CalendarNavigation> navigationDelegate;
@end
