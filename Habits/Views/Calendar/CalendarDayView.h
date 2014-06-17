//
//  CalendarDayView.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Calendar.h"

@interface CalendarDayView : UIView
@property (nonatomic, strong) UILabel * label;
@property (nonatomic, strong) NSDate * day;
-(void)setSelectionState:(CalendarDayState)state color:(UIColor*)color;
@end
