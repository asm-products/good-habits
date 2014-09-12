//
//  StatsPopup.h
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Habit.h"

@interface StatsPopup : UIView
@property (nonatomic, strong) Habit * habit;
@property (nonatomic) CGFloat animateInOutTime;
@property (nonatomic) CGFloat initialSpringVelocity;
@property (nonatomic) CGFloat viewablePixels;
@property (nonatomic) CGFloat springDamping;
-(void)hide;
-(void)animateIn;
-(void)animateOut;
@end
