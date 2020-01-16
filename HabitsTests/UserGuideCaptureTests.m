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
-(NSString*)checkboxFor: (NSString*)name checked: (BOOL) isChecked{
    return [NSString stringWithFormat:@"Checkbox for %@ %@", name, isChecked ? @"Checked" : @"Not checked" ];
}
-(void)testGenerateUserGuideVideo{
    [self addOverlayWindow];
    
    [TestHelpers setStatsEnabled:NO];
    
    [self showNote:@"1. Tap the + to get started"];
    [self tapViewWithAccessibilityLabel:@"add"];
    [self showNote:@"2. Enter new habit title"];
    [tester enterTextIntoCurrentFirstResponder:[self localizedString:@"3. First habit description"]];
    
    [self showNote:@"4. Inform about toggling days"];
    [self tapViewWithAccessibilityLabel:@"Sun required? Yes"];
    [self tapViewWithAccessibilityLabel:@"Sat required? Yes"];
    [self showNote:@"5. Introduce reminders"];
    [self tapViewWithAccessibilityLabel:@"Set reminder"];
    [tester waitForTimeInterval:0.5];
    [self tapViewWithAccessibilityLabel:@"Set reminder"];
    [tester waitForTimeInterval:0.5];
    [self pressBack];
    [self showNote:@"6. Introduce completion checkbox"];
    [self tapViewWithAccessibilityLabel: [self checkboxFor:[self localizedString:@"3. First habit description"] checked:NO]];

    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2013-12-24"].date];
    NSArray * habits = [TestHelpers loadFixtureFromUserDefaultsNamed:@"demo.habits"];
    NSString * firstHabit = [habits firstObject][@"title"];
    NSString * secondHabit = [habits objectAtIndex:1][@"title"];
    
    [self showNote:@"7. Later..."];
    
    [self showNote:@"8. Introduce tapping twice to mark failure"];
    [self tapViewWithAccessibilityLabel: [self checkboxFor:firstHabit checked:NO]];
    [self tapViewWithAccessibilityLabel: [self checkboxFor:firstHabit checked:YES]];
    
    [TestHelpers setStatsEnabled:YES];
    [self showNote:@"9. Introduce in-app purchase chain-break reasons feature"];
    [tester tapViewWithAccessibilityLabel:@"" value:@"Missed today. What happened?" traits:UIAccessibilityTraitNone];
    [tester enterTextIntoCurrentFirstResponder:@"10. Reason for breaking chain"];
    [tester enterTextIntoCurrentFirstResponder:@"\n"];
    [self tapViewWithAccessibilityLabel: firstHabit];
    [self showNote:@"11. Introduce stats button"];
    [self tapViewWithAccessibilityLabel:@"Stats"];
    [self showNote:@"12. Describe stats screen"];
    [tester scrollViewWithAccessibilityIdentifier:@"Stats" byFractionOfSizeHorizontal:0 vertical:-1.0];
    [tester waitForTimeInterval:1.0];
    [self pressBack];
    [self pressBack];
    [self showNote:@"13. Introduce swiping mechanic"];
    UIView * view = [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Habit Cell %@", secondHabit]];
    [view dragFromPoint:CGPointMake(300, 10) toPoint:CGPointMake(150, 10) steps:100];
    [tester waitForTimeInterval:2.0];
    [self showNote:@"14. Add that habits can be paused and deleted by swiping"];
    [view dragFromPoint:CGPointMake(150, 10) toPoint:CGPointMake(300, 10) steps:100];
    
    [self showNote:@"15. It takes about a month to form a new habit"];
    [self showNote:@"16. Have fun, and don't break the chain!"];
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

-(NSString*)localizedString: (NSString*)key{
    NSString * prefixedKey = [NSString stringWithFormat:@"[guide] %@", key];
    return NSLocalizedString(prefixedKey, @"");
}
-(void)showNote:(NSString*)key{
    NSString * localizedText = [self localizedString:key];
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
