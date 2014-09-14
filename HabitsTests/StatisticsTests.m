//
//  StatisticsTests.m
//  Habits
//
//  Created by Michael Forrest on 14/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TimeHelper.h"
#import <YLMoment.h>
#import <KIF.h>
@interface StatisticsTests : XCTestCase

@end

@implementation StatisticsTests
-(void)setUp{
    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-08-04"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"mf.goodtohear.habits"];
}
-(void)testHistograms{
    [tester tapViewWithAccessibilityLabel:@"" value:@"Missed 55 days ago. What happened?" traits:UIAccessibilityTraitNone];
    [tester enterTextIntoCurrentFirstResponder:@"Something bad\n"];
    [tester tapViewWithAccessibilityLabel:@"Pull ups"];
    [tester tapViewWithAccessibilityLabel:@"Stats"];
    [tester waitForTimeInterval:10000];
}
@end
