//
//  CalendarPageViewController.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"
@interface CalendarPageViewController : UIPageViewController
@property (nonatomic, strong) Habit * habit;
-(void)refresh;
@end
