//
//  ChainLengthDistributionTableViewCell.h
//  Habits
//
//  Created by Michael Forrest on 14/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"
@interface ChainLengthDistributionTableViewCell : UITableViewCell
@property (nonatomic, strong) Habit * habit;
@property (nonatomic) CGFloat height;
-(void)refresh;
@end
