//
//  CheckMarkView.m
//  Habits
//
//  Created by Michael Forrest on 12/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CheckMarkView.h"

@implementation CheckMarkView
-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    UIBezierPath* checkMarkPath = [UIBezierPath bezierPath];
    [checkMarkPath moveToPoint: CGPointMake(18.85, 0)];
    [checkMarkPath addLineToPoint: CGPointMake(21.08, 0)];
    [checkMarkPath addLineToPoint: CGPointMake(21.08, 2.92)];
    [checkMarkPath addLineToPoint: CGPointMake(7.2, 18.42)];
    [checkMarkPath addLineToPoint: CGPointMake(0, 11.93)];
    [checkMarkPath addLineToPoint: CGPointMake(0, 9.21)];
    [checkMarkPath addLineToPoint: CGPointMake(2.36, 9.21)];
    [checkMarkPath addLineToPoint: CGPointMake(7.2, 12.97)];
    [checkMarkPath addLineToPoint: CGPointMake(18.85, 0)];
    [checkMarkPath closePath];
    checkMarkPath.miterLimit = 4;


    
    [self.color setFill];
    [checkMarkPath fill];
}
@end
