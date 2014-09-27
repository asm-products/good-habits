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
#import <OCMock.h>
#import "HabitCell.h"

#define GRABS_PATH @"/Users/mf/code/habits/Habits/Habits/Images/grabs"

@interface HabitCell(TestingHacks)
@end
@implementation HabitCell(TestingHacks)
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
@end

@interface UserGuideCaptureTests : XCTestCase

@end

@implementation UserGuideCaptureTests

- (void)setUp {
    [super setUp];
    [HabitsQueries deleteAllHabits];
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
    NSArray * grabs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:GRABS_PATH error:nil];
    for (NSString * path in grabs) {
        NSLog(@"Delete %@", path);
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:[GRABS_PATH stringByAppendingPathComponent: path] error:&error];
        if(error) NSLog(@"error: %@", error);
    }
}

-(void)testGrabAllScreens{
    [TestHelpers setStatsEnabled:NO];
    
    [self showNote:@"Tap the + to get started"];
    [tester tapViewWithAccessibilityLabel:@"add"];
    [self showNote:@"Enter the title"];
    [tester enterTextIntoCurrentFirstResponder:@"Floss\n"];
    [self screenshot:@"floss"];
    [self showNote:@"Maybe you don't need to do it every day"];
    [tester tapViewWithAccessibilityLabel:@"Sun required? Yes"];
    [tester tapViewWithAccessibilityLabel:@"Sat required? Yes"];
    [self screenshot:@"unchecked_days"];
    [self showNote:@"Set a reminder"];
    [tester tapViewWithAccessibilityLabel:@"Set reminder"];
    [tester waitForTimeInterval:0.5];
    [tester tapViewWithAccessibilityLabel:@"Set reminder"];
    [tester waitForTimeInterval:0.5];
    [self screenshot:@"reminder_set"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [self showNote:@"Check the box when you've done it"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Floss Not checked"];
    [self screenshot:@"checked_today"];

    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2013-12-24"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"demo.habits"];
    [self showNote:@"Later..."];
    
    [self showNote:@"If you missed today, you can tap the box twice"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Floss Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Floss Checked"];
    [self screenshot:@"missed"];
    
    [TestHelpers setStatsEnabled:YES];
    [self showNote:@"With stats enabled (in app purchase) you can record the reasons for your chain break."];
    [tester tapViewWithAccessibilityLabel:@"" value:@"Missed today. What happened?" traits:UIAccessibilityTraitNone];
    [tester enterTextIntoCurrentFirstResponder:@"I ran out of floss"];
    [self screenshot:@"showing_keyboard"];
    [tester enterTextIntoCurrentFirstResponder:@"\n"];
    [tester tapViewWithAccessibilityLabel:@"Floss"];
    [self showNote:@"See stats with the top-right button"];
    [tester tapViewWithAccessibilityLabel:@"Stats"];
    [self screenshot:@"stats"];
    [self showNote:@"You'll see chain information and also a list of reasons you missed a day"];
    [tester scrollViewWithAccessibilityIdentifier:@"Stats" byFractionOfSizeHorizontal:0 vertical:-1.0];
    [tester waitForTimeInterval:1.0];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [self showNote:@"If you didn't open the app for a few days but didn't miss any days, you can check them off by swiping the list"];
    UIView * view = [tester waitForViewWithAccessibilityLabel:@"Habit Cell Exercise"];
    [view dragFromPoint:CGPointMake(300, 10) toPoint:CGPointMake(150, 10) steps:100];
    [tester waitForTimeInterval:2.0];
    [self showNote:@"You can also pause or delete habits this way"];
    [view dragFromPoint:CGPointMake(150, 10) toPoint:CGPointMake(300, 10) steps:100];
    
    [self showNote:@"It takes about a month to form a new habit."];
    [self showNote:@"Have fun, and don't break the chain!"];
    
}
-(void)showNote:(NSString*)text{
    NSString * filename = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    HelpCaptureInterstitialViewController * controller = [[HelpCaptureInterstitialViewController alloc] initWithTitle:text detail:nil];
    
    controller.view.alpha = 0;
    [FCOverlay presentOverlayWithViewController:controller windowLevel:UIWindowLevelAlert animated:NO completion:^{
        controller.view.superview.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            controller.view.alpha = 1;
        }];
    }];
    [tester waitForTimeInterval:2];
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
    NSString * outputPath = [GRABS_PATH stringByAppendingPathComponent:filename];
    outputPath = [outputPath stringByAppendingPathExtension:@"jpg"];
    NSLog(@"Saving file to %@", outputPath);
    [UIImagePNGRepresentation(image) writeToFile:outputPath atomically:YES];
}
@end
