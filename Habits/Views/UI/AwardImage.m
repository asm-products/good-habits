//
//  AwardImage.m
//  Habits
//
//  Created by Michael Forrest on 19/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AwardImage.h"

@implementation AwardImage
+(NSMutableDictionary*)cachedStars{
    static NSMutableDictionary * result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NSMutableDictionary alloc] initWithCapacity:10];
    });
    return result;
}
+(UIImage *)starColored:(UIColor *)color{
    UIImage * cached = [self cachedStars][color];
    if(cached){
        return cached;
    }
    static UIBezierPath* starPath = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        starPath = [UIBezierPath bezierPath];
        [starPath moveToPoint: CGPointMake(22, 4)];
        [starPath addLineToPoint: CGPointMake(25.19, 7)];
        [starPath addLineToPoint: CGPointMake(29.32, 5.56)];
        [starPath addLineToPoint: CGPointMake(31.01, 9.59)];
        [starPath addLineToPoint: CGPointMake(35.38, 9.96)];
        [starPath addLineToPoint: CGPointMake(35.28, 14.33)];
        [starPath addLineToPoint: CGPointMake(39.12, 16.44)];
        [starPath addLineToPoint: CGPointMake(37.25, 20.4)];
        [starPath addLineToPoint: CGPointMake(39.9, 23.88)];
        [starPath addLineToPoint: CGPointMake(36.59, 26.74)];
        [starPath addLineToPoint: CGPointMake(37.59, 31)];
        [starPath addLineToPoint: CGPointMake(33.4, 32.26)];
        [starPath addLineToPoint: CGPointMake(32.58, 36.56)];
        [starPath addLineToPoint: CGPointMake(28.24, 36.01)];
        [starPath addLineToPoint: CGPointMake(25.74, 39.61)];
        [starPath addLineToPoint: CGPointMake(22, 37.34)];
        [starPath addLineToPoint: CGPointMake(18.26, 39.61)];
        [starPath addLineToPoint: CGPointMake(15.76, 36.01)];
        [starPath addLineToPoint: CGPointMake(11.42, 36.56)];
        [starPath addLineToPoint: CGPointMake(10.6, 32.26)];
        [starPath addLineToPoint: CGPointMake(6.41, 31)];
        [starPath addLineToPoint: CGPointMake(7.41, 26.74)];
        [starPath addLineToPoint: CGPointMake(4.1, 23.88)];
        [starPath addLineToPoint: CGPointMake(6.75, 20.4)];
        [starPath addLineToPoint: CGPointMake(4.88, 16.44)];
        [starPath addLineToPoint: CGPointMake(8.72, 14.33)];
        [starPath addLineToPoint: CGPointMake(8.62, 9.96)];
        [starPath addLineToPoint: CGPointMake(12.99, 9.59)];
        [starPath addLineToPoint: CGPointMake(14.68, 5.56)];
        [starPath addLineToPoint: CGPointMake(18.81, 7)];
        [starPath closePath];

    });
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(44, 44),NO, 0);
    [color setFill];
    [starPath fill];
//    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 44, 44)] stroke];
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self cachedStars][color] = result;
    return result;
}
+(NSMutableDictionary*)cachedCircles{
    static NSMutableDictionary * result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NSMutableDictionary alloc] initWithCapacity:10];
    });
    return result;
}
+(UIImage *)circleColored:(UIColor *)color{
    UIImage * cached = [self cachedCircles][color];
    if(cached){
        return cached;
    }
    static UIBezierPath * path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(CGRectMake(0, 0, 44, 44), 7, 7)];
    });

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(44, 44),NO, 0);
    [color setFill];
    [path fill];
    //    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 44, 44)] stroke];
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self cachedCircles][color] = result;
    return result;
 
}
@end
