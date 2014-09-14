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
    __weak IBOutlet UILabel * titleLabel;
    __weak IBOutlet DailySparklineView * sparkline;
    __weak IBOutlet UILabel * periodLabel;
    NSTimer * dismissTimer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self build];
    }
    return self;
}
-(void)awakeFromNib{
    [self build];
}
-(void)build{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowRadius = 1;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.1;
    [self addDismissGesture];
}
-(void)setHabit:(Habit *)habit{
    _habit = habit;
    
    titleLabel.text = habit.title.uppercaseString;
    NSDate * earliestDate = habit.earliestDate;
    if(earliestDate){ // can't be bothered to figure this out right now.
        periodLabel.text = [SparklineHelper periodText:habit.earliestDate].uppercaseString;
    }else{
        periodLabel.text = @"";
    }
    sparkline.color = habit.color;
    sparkline.chains = [SparklineHelper dataForHabit:habit];
    [sparkline setNeedsDisplay];
}
-(void)addDismissGesture{
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanned:)];
    [self addGestureRecognizer:pan];
}
-(void)onPanned:(UIPanGestureRecognizer*)pan{
    [dismissTimer invalidate];
    if(pan.state == UIGestureRecognizerStateEnded) {
        if (self.frame.origin.y > self.superview.frame.size.height - self.viewablePixels)
            [self animateOut];
        else
            [self animateRestore];
    }else{
        CGPoint offset = [pan translationInView:self];
        CGPoint center = self.center;
        CGFloat distanceFromFullyExtended = (self.superview.frame.size.height - self.viewablePixels - self.frame.origin.y);
        CGFloat dampingMultiplier = 1.0 - (distanceFromFullyExtended / 100);
        
        center.y += offset.y * MIN(1.0, dampingMultiplier);
        self.center = center;
        [pan setTranslation:CGPointZero inView:self];
    }
}

- (void)animateIn
{
    [UIView animateWithDuration:self.animateInOutTime delay:0 usingSpringWithDamping:self.springDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
     {
         self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.viewablePixels, self.frame.size.width, self.frame.size.height);
     } completion:^(BOOL finished) {
         [self restartDismissTimer];
     }];
}
-(void)hide{
    self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height, self.frame.size.width, self.frame.size.height);
}
- (void)animateOut
{
    [UIView animateWithDuration:self.animateInOutTime delay:0 usingSpringWithDamping:self.springDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
     {
         [self hide];
         
     } completion:nil];
}

- (void)animateRestore
{
    [UIView animateWithDuration:self.animateInOutTime delay:0 usingSpringWithDamping:self.springDamping initialSpringVelocity:self.initialSpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^(void)
     {
         self.frame = CGRectMake(self.frame.origin.x, self.superview.frame.size.height - self.viewablePixels, self.frame.size.width, self.frame.size.height);
     } completion:^(BOOL finished) {
         [self restartDismissTimer];
     }];
}
-(void)restartDismissTimer{
    
    [dismissTimer invalidate];
    dismissTimer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(animateOut) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:dismissTimer forMode:NSDefaultRunLoopMode];
    
}
@end
