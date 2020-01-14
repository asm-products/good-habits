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
#import "HelpCaptureInterstitialViewController.h"
#import <KIF.h>
#import <YLMoment.h>
#import <UIImage+Screenshot.h>
#import <OCMock.h>
#import "HabitCell.h"
#import "TimeHelper.h"
#import "UserGuideCaptureOverlayViewController.h"

#define GRABS_PATH @"/Users/mf/code/habits/Habits/fastlane/screenshots"

@interface HabitCell(TestingHacks)
@end
@implementation HabitCell(TestingHacks)
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}
@end

@interface UserGuideCaptureTests : KIFTestCase
@property (nonatomic, strong) UserGuideCaptureOverlayViewController * userGuideCaptureOverlayController;
@end

@implementation UserGuideCaptureTests

- (void)setUp {
    [super setUp];
    [HabitsQueries deleteAllHabits];
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
    
    
}
-(void)pressBack{
    NSString * back = NSLocalizedString(@"Back", @"");
    [tester tapViewWithAccessibilityLabel:back];
}
-(void)addOverlayWindow{
    CGRect frame = [UIScreen mainScreen].bounds;
    UIWindow * window = [[UIWindow alloc] initWithFrame:frame];
    self.userGuideCaptureOverlayController = [[UserGuideCaptureOverlayViewController alloc] init];
    
    window.rootViewController = self.userGuideCaptureOverlayController;
    [window makeKeyAndVisible];
}
-(void)removeOverlayWindow{
    
}
-(void)testGenerateUserGuideVideo{
    [self addOverlayWindow];
    
    [TestHelpers setStatsEnabled:NO];
    
    [self showNote:@"Tap the + to get started"];
    [self tapViewWithAccessibilityLabel:@"add"];
    [self showNote:@"Enter the title"];
    [tester enterTextIntoCurrentFirstResponder:@"Floss\n"];
    [self showNote:@"Maybe you don't need to do it every day"];
    [self tapViewWithAccessibilityLabel:@"Sun required? Yes"];
    [self tapViewWithAccessibilityLabel:@"Sat required? Yes"];
    [self showNote:@"Set a reminder"];
    [self tapViewWithAccessibilityLabel:@"Set reminder"];
    [tester waitForTimeInterval:0.5];
    [self tapViewWithAccessibilityLabel:@"Set reminder"];
    [tester waitForTimeInterval:0.5];
    [self pressBack];
    [self showNote:@"Check the box when you've done it"];
    [self tapViewWithAccessibilityLabel:@"Checkbox for Floss Not checked"];

    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2013-12-24"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"demo.habits"];
    [self showNote:@"Later..."];
    
    [self showNote:@"If you missed today, you can tap the box twice"];
    [self tapViewWithAccessibilityLabel:@"Checkbox for Floss Not checked"];
    [self tapViewWithAccessibilityLabel:@"Checkbox for Floss Checked"];
    
    [TestHelpers setStatsEnabled:YES];
    [self showNote:@"With stats enabled (in app purchase) you can record the reasons for your chain break."];
    [tester tapViewWithAccessibilityLabel:@"" value:@"Missed today. What happened?" traits:UIAccessibilityTraitNone];
    [tester enterTextIntoCurrentFirstResponder:@"I ran out of floss"];
    [tester enterTextIntoCurrentFirstResponder:@"\n"];
    [self tapViewWithAccessibilityLabel:@"Floss"];
    [self showNote:@"See stats with the top-right button"];
    [self tapViewWithAccessibilityLabel:@"Stats"];
    [self showNote:@"You'll see chain information and also a list of reasons you missed a day"];
    [tester scrollViewWithAccessibilityIdentifier:@"Stats" byFractionOfSizeHorizontal:0 vertical:-1.0];
    [tester waitForTimeInterval:1.0];
    [self pressBack];
    [self pressBack];
    [self showNote:@"If you didn't open the app for a few days but didn't miss any days, you can check them off by swiping the list"];
    UIView * view = [tester waitForViewWithAccessibilityLabel:@"Habit Cell Exercise"];
    [view dragFromPoint:CGPointMake(300, 10) toPoint:CGPointMake(150, 10) steps:100];
    [tester waitForTimeInterval:2.0];
    [self showNote:@"You can also pause or delete habits this way"];
    [view dragFromPoint:CGPointMake(150, 10) toPoint:CGPointMake(300, 10) steps:100];
    
    [self showNote:@"It takes about a month to form a new habit."];
    [self showNote:@"Have fun, and don't break the chain!"];
}
// shows a "tap" animation
-(void)tapViewWithAccessibilityLabel: (NSString*)label{
    UIView *view = nil;
    UIAccessibilityElement *element = nil;
    [tester waitForAccessibilityElement:&element view:&view withLabel:label value:nil traits:UIAccessibilityTraitNone tappable:YES];
    CGRect rect = [view.window convertRect:view.bounds fromView:view];
    [self.userGuideCaptureOverlayController showTapInRect: rect];
    [tester tapViewWithAccessibilityLabel:label];
}
-(void)showNote:(NSString*)text{
    NSString * filename = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * localizedText = NSLocalizedString(text, @"");
    HelpCaptureInterstitialViewController * controller = [[HelpCaptureInterstitialViewController alloc] initWithTitle:localizedText detail:nil];
    controller.extendedLayoutIncludesOpaqueBars = true;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.userGuideCaptureOverlayController presentViewController:controller animated:true completion:^{
    }];
    [tester waitForTimeInterval:2];
//    [self screenshot:filename];
    [controller dismissViewControllerAnimated:true completion:nil];
    [tester waitForTimeInterval:0.3];
}
-(NSString*)screenSizeName{
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    if(h == 568) return @"4.0"; // iPhone 5
    if(h == 667) return @"4.7"; // iPhone 6
    if(h == 736) return @"5.5"; // iPhone 6 Plus
    if(h == 812) return @"5.8"; // iPhone X
    if(h == 896) return @"6.1"; // iPhone 11
    if(h == 1366) return @"12.9"; // iPad Pro
    return @"dunno";
}
@end
