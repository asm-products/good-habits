//
//  StatisticsTests.m
//  Habits
//
//  Created by Michael Forrest on 14/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KIF.h>
#import "TimeHelper.h"
@interface StatisticsTests : KIFTestCase

@end

@implementation StatisticsTests
-(void)setUp{
    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2014-08-04"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"mf.goodtohear.habits"];
}
-(void)testHistograms{
    [tester tapViewWithAccessibilityLabel:@"Missed Jun 3, 2014. What happened?"];
    [tester enterTextIntoCurrentFirstResponder:@"Something bad\n"];
    [tester tapViewWithAccessibilityLabel:@"Rehearsal"];
    [tester tapViewWithAccessibilityLabel:@"Stats"];
}
@end
