//
//  UserGuideCaptureTests.m
//  Habits
//
//  Created by Michael Forrest on 14/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//
#import <UIApplication-KIFAdditions.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <FCOverlay.h>
#import "HelpCaptureInterstitialViewController.h"
#import <KIF.h>
#import <YLMoment.h>
#import "HabitsQueries.h"
#import "TimeHelper.h"
#import <UIImage+Screenshot.h>
@interface UserGuideCaptureTests : XCTestCase

@end

@implementation UserGuideCaptureTests

- (void)setUp {
    [super setUp];
    [HabitsQueries deleteAllHabits];
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
}

-(void)testGrabAllScreens{
//    [TestHelpers setStatsEnabled:NO];
    
//    [self showNote:@"Tap the + to get started"];
//    [tester tapViewWithAccessibilityLabel:@"add"];
//    [self showNote:@"Enter the title"];
//    [tester enterTextIntoCurrentFirstResponder:@"Floss\n"];
//    [self showNote:@"Maybe you don't need to do it every day"];
//    [tester tapViewWithAccessibilityLabel:@"Sun required? Yes"];
//    [tester tapViewWithAccessibilityLabel:@"Sat required? Yes"];
//    [self showNote:@"Set a reminder"];
//    [tester tapViewWithAccessibilityLabel:@"Set reminder"];
//    [tester tapViewWithAccessibilityLabel:@"Set reminder"];
//    [tester tapViewWithAccessibilityLabel:@"Back"];
//    [self showNote:@"Check the box when you've done it"];
//    [tester tapViewWithAccessibilityLabel:@"Checkbox for Floss Not checked"];
    
    
    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2013-12-24"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"demo.habits"];
    [self showNote:@"Later..." screenshot:@"later"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Floss Not checked"];
    [self showNote:@"If you missed today, you can tap the box again" screenshot:@"missed-today"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Floss Checked"];
    
    [TestHelpers setStatsEnabled:YES];
    [self showNote:@"With stats enabled (in app purchase) you can record the reasons for your chain break." screenshot:@"enable-stats"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Exercise Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Exercise Checked"];
    [tester tapViewWithAccessibilityLabel:@"Play the trumpet"];
    [tester tapViewWithAccessibilityLabel:@"Stats"];
    
    [self screenshot:@"stats"];
    [tester waitForTimeInterval:100];
    
}
-(void)showNote:(NSString*)text screenshot:(NSString*)filename{
    HelpCaptureInterstitialViewController * controller = [[HelpCaptureInterstitialViewController alloc] initWithTitle:text detail:nil];
    
    controller.view.alpha = 0;
    [FCOverlay presentOverlayWithViewController:controller windowLevel:UIWindowLevelAlert animated:NO completion:^{
        controller.view.superview.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            controller.view.alpha = 1;
        }];
    }];
    [tester waitForTimeInterval:1];
    [self screenshot:filename];
    [UIView animateWithDuration:0.3 animations:^{
        controller.view.alpha = 0;
    } completion:^(BOOL finished) {
        [FCOverlay dismissOverlayAnimated:NO completion:nil];
    }];
    [tester waitForTimeInterval:0.3];
}
-(void)screenshot:(NSString*)name{
    static NSInteger screenshotIndex = 0;
    screenshotIndex ++;
    UIImage * image = [UIImage screenshot];
//    UIImage * sta[UIImage imageNamed:@"status-bar"];
    NSString * filename = [NSString stringWithFormat:@"%@ - %@", @(screenshotIndex), name];
    NSString * outputPath = @"/Users/mf/code/habits/Habits/Habits/Images/grabs";
    outputPath = [outputPath stringByAppendingPathComponent:filename];
    outputPath = [outputPath stringByAppendingPathExtension:@"jpg"];
    NSLog(@"Saving file to %@", outputPath);
    [UIImagePNGRepresentation(image) writeToFile:outputPath atomically:YES];
}
@end
