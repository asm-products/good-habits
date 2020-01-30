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

@interface AppStoreScreenshotCaptureTests : KIFTestCase
@end

@implementation AppStoreScreenshotCaptureTests

- (void)setUp {
    [super setUp];
    [HabitsQueries deleteAllHabits];
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
    
    
}
-(void)deleteAllGrabs{
    NSArray * grabs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:GRABS_PATH error:nil];
    for (NSString * path in grabs) {
        NSLog(@"Delete %@", path);
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:[GRABS_PATH stringByAppendingPathComponent: path] error:&error];
        if(error) NSLog(@"error: %@", error);
    }
}
-(void)testGrabAppStoreScreens{
    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2013-12-24"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"appstore.habits"];
    [TestHelpers setStatsEnabled:YES];
    [tester waitForTimeInterval:0.4];
    [self screenshot:@"screenshot_1"];
    [tester tapViewWithAccessibilityLabel:LocalizedString(@"Floss", @"")];
    [tester waitForTimeInterval:0.4];
    [self screenshot:@"screenshot_2"];
    [tester tapViewWithAccessibilityLabel:@"Stats"];
    [tester waitForTimeInterval:0.4];
    [self screenshot:@"screenshot_3"];
    [self pressBack];
    [self pressBack];
}
-(void)pressBack{
    NSString * back = LocalizedString(@"Back", @"");
    [tester tapViewWithAccessibilityLabel:back];
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
-(NSString*)deviceName{
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    if(h == 568) return @"iPhone 5"; //
    if(h == 667) return @"iPhone 6"; //
    if(h == 736) return @"iPhone 6 Plus"; //
    if(h == 812) return @"iPhone X"; //
    if(h == 896) return @"iPhone 11"; //
    if(h == 1366) return @"iPad Pro"; // 
    return @"dunno";
}
-(void)screenshot:(NSString*)name{
    static NSInteger screenshotIndex = 0;
    screenshotIndex ++;
    UIImage * image = [UIImage screenshot];
    NSString * languageCode = [NSLocale currentLocale].languageCode;
    NSString * dir = [[GRABS_PATH stringByAppendingPathComponent: languageCode] stringByReplacingOccurrencesOfString:@"_" withString:@"-" ];
    if(NO == [[NSFileManager defaultManager] fileExistsAtPath:dir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * filename = [NSString stringWithFormat:@"%@-%@-%@", [self deviceName], @(screenshotIndex), name];
    NSString * outputPath = [dir stringByAppendingPathComponent:filename];
    NSLog(@"Saving file to %@", outputPath);
//    [UIImageJPEGRepresentation(image, 100) writeToFile:[outputPath stringByAppendingPathExtension:@"jpg"] atomically:YES];
//    NSLog(@"SKIP WRITING TO %@", outputPath);
    [UIImagePNGRepresentation(image) writeToFile:[outputPath stringByAppendingPathExtension:@"png"] atomically:YES];
    
}
@end
