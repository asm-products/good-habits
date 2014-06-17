//
//  DayPicker.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"

@class DayPicker;

@protocol DayPickerDelegate <NSObject>
-(Habit*)habit;
-(void)dayPickerDidChange:(DayPicker*)sender;
@end

@interface DayPicker : UIView
@property (nonatomic, strong) Habit * habit;
@property (nonatomic, weak) IBOutlet id<DayPickerDelegate> delegate;
-(id)initWithFrame:(CGRect)frame habit:(Habit*)habit;
@end
