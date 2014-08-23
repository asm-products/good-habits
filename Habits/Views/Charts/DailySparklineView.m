//
//  DailySparklineView.m
//  Habits
//
//  Created by Michael Forrest on 10/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DailySparklineView.h"
#import "Colors.h"
#import <NSArray+F.h>
#import "HabitDay.h"
#import "Chain.h"
#define INSET 2
#define SCALE 1.0

@implementation DailySparklineView{
}
-(void)awakeFromNib{
    
}
-(UIBezierPath*)checkPath{
  UIBezierPath* bezierPath = nil;
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(3.25, 0.83)];
    [bezierPath addLineToPoint: CGPointMake(3.58, 0.83)];
    [bezierPath addLineToPoint: CGPointMake(3.58, 1.22)];
    [bezierPath addLineToPoint: CGPointMake(1.55, 3.25)];
    [bezierPath addLineToPoint: CGPointMake(0.5, 2.4)];
    [bezierPath addLineToPoint: CGPointMake(0.5, 2.04)];
    [bezierPath addLineToPoint: CGPointMake(0.84, 2.04)];
    [bezierPath addLineToPoint: CGPointMake(1.55, 2.54)];
    [bezierPath addLineToPoint: CGPointMake(3.25, 0.83)];
    [bezierPath closePath];
    [bezierPath applyTransform:CGAffineTransformMakeScale(SCALE, SCALE)];
    return bezierPath;
}
-(UIBezierPath*)checkBoxPath{
    return [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 4 * SCALE, 4 * SCALE)];;
}
-(CGSize)unitSize:(NSArray*)dataPoints bounds:(CGRect)bounds{
    CGFloat step = bounds.size.width / [[dataPoints valueForKeyPath:@"@sum.length"] floatValue];
    NSInteger max = [[dataPoints reduce:^id(id memo, Chain * chain) {
        return @(MAX([memo integerValue], chain.length));
    } withInitialMemo:@0] integerValue];
    CGFloat verticalStep = max != 0 ? bounds.size.height / (CGFloat) max : 0;
    return CGSizeMake(step, verticalStep);
}
-(CGPoint)pointForStepWithUnitSize:(CGSize)unit index:(NSInteger)index value:(CGFloat)value bounds:(CGSize)bounds{
    return CGPointMake( unit.width * (CGFloat)index ,
                       bounds.height - value * unit.height);
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect bounds = CGRectInset(self.bounds, INSET, INSET);
    if(self.dataPoints.count < 3) return;
    CGSize unit = [self unitSize:self.dataPoints bounds:bounds];
    UIBezierPath * checkBoxPath = [self checkBoxPath];
    UIBezierPath * checkPath = [self checkPath];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, INSET, INSET);
    
    UIBezierPath * path = [UIBezierPath new];

    __block NSInteger chainOffset = 0;
    
    [self.dataPoints enumerateObjectsUsingBlock:^(Chain * chain, NSUInteger chainIndex, BOOL *stop) {
        [chain.sortedDays enumerateObjectsUsingBlock:^(HabitDay * habitDay, NSUInteger idx, BOOL *stop) {
            CGPoint p = [self pointForStepWithUnitSize:unit index:idx + chainOffset value:habitDay.runningTotalCache.floatValue bounds:bounds.size];
            if(idx == 0){
                [path moveToPoint:p];
            }else{
                [path addLineToPoint:p];
            }
        }];
        chainOffset += chain.length;
    }];
    path.lineWidth = 1.0;
    path.lineJoinStyle = kCGLineJoinBevel;
    [self.color setStroke];
    [path stroke];
    
    chainOffset = 0;
    [self.dataPoints enumerateObjectsUsingBlock:^(Chain * chain, NSUInteger chainIndex, BOOL *stop) {
        if(chain.length > 0){
            [chain.sortedDays enumerateObjectsUsingBlock:^(HabitDay * habitDay, NSUInteger dayIndex, BOOL *stop) {
                CGPoint p = [self pointForStepWithUnitSize:unit index:chainOffset + dayIndex value:[habitDay.runningTotalCache floatValue] bounds:bounds.size];
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, p.x - 2 * SCALE, p.y - 2 * SCALE);
                
                [self.color setFill];
                [checkBoxPath fill];
                
                [[UIColor whiteColor] setFill];
                [checkPath fill];
                CGContextRestoreGState(context);
            }];
        }
        chainOffset += chain.length;
    }];
}

@end
