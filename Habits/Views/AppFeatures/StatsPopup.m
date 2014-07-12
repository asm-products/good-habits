//
//  StatsPopup.m
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "StatsPopup.h"
#import "Colors.h"
#import "DailySparklineView.h"
#import "SparklineHelper.h"
@implementation StatsPopup{
    UILabel * titleLabel;
    DailySparklineView * sparkline;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self build];
    }
    return self;
}
-(void)build{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowRadius = 1;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.1;
    self.layer.shouldRasterize = YES;
    [self addTitleLabel];
    [self addSparkline];
    [self addDismissGesture];
}
-(void)addTitleLabel{
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.height, 12)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:9];
    titleLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:titleLabel];
}
-(void)addSparkline{
    sparkline = [[DailySparklineView alloc] initWithFrame:CGRectInset(self.bounds, 15, 15)];
    sparkline.backgroundColor = [UIColor whiteColor];
    [self addSubview:sparkline];
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    
    titleLabel.text = habit.title.uppercaseString;
    sparkline.color = habit.color;
    sparkline.dataPoints = [SparklineHelper dataForHabit:habit];
    [sparkline setNeedsDisplay];
}
-(void)addDismissGesture{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self addGestureRecognizer:pan];
}
-(void)didPan:(UIPanGestureRecognizer*)pan{
    CGPoint translation = [pan translationInView:self];
    self.center = CGPointMake(self.center.x, self.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self];
}
@end
