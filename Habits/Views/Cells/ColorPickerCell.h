//
//  ColorPickerCell.h
//  Habits
//
//  Created by Michael Forrest on 07/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"

#define HABIT_COLOR_CHANGED @"HABIT_COLOR_CHANGED"

@interface ColorPickerCell : UITableViewCell
@property (nonatomic, strong) Habit * habit;
@end
