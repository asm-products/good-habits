//
//  HabitDetailViewController.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"
@interface HabitDetailViewController : UITableViewController
@property (nonatomic, strong) Habit * habit;
@end
