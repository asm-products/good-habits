//
//  HabitCell.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CellWithCheckBox.h"
#import "Chain.h"
#define TODAY_CHECKED_FOR_CHAIN @"TODAY_CHECKED_FOR_CHAIN"
#define CHAIN_MODIFIED @"CHAIN_MODIFIED"

@interface HabitCell : CellWithCheckBox
@property (nonatomic, strong) Chain * chain;
@property (nonatomic) BOOL inactive;
@property (nonatomic, strong) NSDate * day;
@property (nonatomic) DayCheckedState state;
@property (nonatomic, weak) UIViewController * delegate;
-(void)update;
@end
