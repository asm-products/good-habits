//
//  CheckBox.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chain.h"
@interface CheckBox : UIView
@property (nonatomic, strong) UIColor * color;
@property (nonatomic) DayCheckedState state;
@property (nonatomic, strong) NSString * label;
-(void)setState:(DayCheckedState)state animated: (BOOL)animated;
@end
