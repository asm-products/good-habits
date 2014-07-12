//
//  HabitListViewController.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATSDragToReorderTableViewController.h"
#import "Habit.h"
@interface HabitListViewController : ATSDragToReorderTableViewController<ATSDragToReorderTableViewControllerDelegate>
-(void)refresh;
-(void)insertHabit:(Habit*)habit;
@end
