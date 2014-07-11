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

#define INSET 2

@implementation DailySparklineView{
    CAShapeLayer * lineLayer;
}
-(void)awakeFromNib{
    
}
-(CAShapeLayer*)createLineLayer{
    lineLayer = [CAShapeLayer layer];
    lineLayer.frame = CGRectInset(self.bounds, INSET, INSET);
    lineLayer.strokeColor = [Colors green].CGColor;
    lineLayer.lineWidth = 1.0;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:lineLayer];
    return lineLayer;
}
-(void)setColor:(UIColor *)color{
    _color = color;
    lineLayer.strokeColor = color.CGColor;
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
    return bezierPath;
}
-(UIBezierPath*)checkBoxPath{
    return [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 4, 4)];;
}
-(CGSize)unitSize:(NSArray*)dataPoints bounds:(CGRect)bounds{
    CGFloat step = bounds.size.width / (CGFloat) dataPoints.count;
    NSInteger max = [[dataPoints reduce:^id(id memo, id obj) {
        return @(MAX([memo integerValue], [obj integerValue]));
    } withInitialMemo:@0] integerValue];
    CGFloat verticalStep = bounds.size.height / (CGFloat) max;
    return CGSizeMake(step, verticalStep);
}
-(CGPoint)pointForStepWithUnitSize:(CGSize)unit index:(NSInteger)index value:(CGFloat)value bounds:(CGSize)bounds{
    return CGPointMake( unit.width * (CGFloat)index ,
                       bounds.height - value * unit.height);
}
-(void)setDataPoints:(NSArray *)dataPoints{
    _dataPoints = dataPoints;
    if(dataPoints.count < 3) return;
    CGRect bounds = CGRectInset(self.bounds, INSET, INSET);
    CGSize unit = [self unitSize:dataPoints bounds:bounds];
    
    UIBezierPath * path = [UIBezierPath new];
    [dataPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint p = [self pointForStepWithUnitSize:unit index:idx value:[obj floatValue] bounds:bounds.size];
        if(idx == 0){
            [path moveToPoint:p];
        }else{
            [path addLineToPoint:p];
        }
    }];
    path.lineJoinStyle = kCGLineJoinBevel;
    if(!lineLayer) lineLayer = [self createLineLayer];
    lineLayer.path = path.CGPath;
    [lineLayer setNeedsDisplay];
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if(self.dataPoints.count < 3) return;
    CGSize unit = [self unitSize:self.dataPoints bounds:lineLayer.bounds];
    UIBezierPath * checkBoxPath = [self checkBoxPath];
    UIBezierPath * checkPath = [self checkPath];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, INSET, INSET);
    [self.dataPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj floatValue] > 0){
            CGPoint p = [self pointForStepWithUnitSize:unit index:idx value:[obj floatValue] bounds:lineLayer.bounds.size];
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, p.x - 2, p.y - 2);

            [self.color setFill];
            [checkBoxPath fill];
            
            [[UIColor whiteColor] setFill];
            [checkPath fill];
            CGContextRestoreGState(context);
        }
    }];
}

@end
