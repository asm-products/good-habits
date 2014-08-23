//
//  HabitCell.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CellWithCheckBox.h"
#import "Chain.h"
#define DAY_TOGGLED_FOR_HABIT @"DAY_TOGGLED_FOR_HABIT"

@interface HabitCell : CellWithCheckBox
@property (nonatomic, strong) Chain * chain;
@property (nonatomic) BOOL inactive;
@property (nonatomic, strong) NSDate * now;
@property (nonatomic) DayCheckedState state;
-(void)update;
@end
