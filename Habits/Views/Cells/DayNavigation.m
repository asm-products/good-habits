//
//  DayNavigation.m
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DayNavigation.h"
#import "Colors.h"
@implementation DayNavigation


-(instancetype)init{
    if(self = [super init]){
        [self build];
    }
    return self;
}
-(void)build{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    [self addSubview:label];
    self.textLabel = label;
    
    self.backgroundColor = [Colors cobalt];
}
-(void)setDate:(NSDate *)date{
    _date = date;
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"EEEE d MMMM";
    });
    self.textLabel.text = [formatter stringFromDate:date];
}
@end
