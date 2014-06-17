//
//  DayToggle.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayToggle : UIButton
@property (nonatomic) BOOL isOn;
@property (nonatomic, strong) NSString * day;
@property (nonatomic, strong) UIColor * color;
-(id)initWithFrame:(CGRect)frame day:(NSString*)day color:(UIColor*)color isOn:(BOOL)isOn;
-(void)toggleOn:(BOOL)isOn;
@end
