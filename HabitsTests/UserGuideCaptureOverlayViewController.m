//
//  UserGuideCaptureOverlayViewController.m
//  HabitsTests
//
//  Created by Michael Forrest on 09/01/2020.
//  Copyright © 2020 Good To Hear. All rights reserved.
//

#import "UserGuideCaptureOverlayViewController.h"

@interface UserGuideCaptureOverlayViewController ()<UIGestureRecognizerDelegate>

@end

@implementation UserGuideCaptureOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor greenColor];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
}

-(void)handleTap: (UITapGestureRecognizer*)tap{
    CGPoint point = [tap locationInView:self.view];
    NSLog(@"TAPPED AT", NSStringFromCGPoint(point));
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


-(void)showTapInRect:(CGRect)rect{
    CGFloat size = 44;
    CGFloat left = CGRectGetMidX(rect) - size / 2;
    CGFloat top = CGRectGetMidY(rect) - size / 2;
    CGRect circleRect = CGRectMake(left, top, size, size);
    UIView * view = [[UIView alloc] initWithFrame:circleRect];
    view.backgroundColor = [UIColor systemPinkColor];
    view.layer.cornerRadius = size / 2;
    [self.view addSubview:view];
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}
@end
