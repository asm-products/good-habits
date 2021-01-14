//
//  TrendsTest.m
//  HabitsTests
//
//  Created by Michael Forrest on 13/01/2021.
//  Copyright © 2021 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KIF.h>
#import "TimeHelper.h"

@interface TrendsTest: KIFTestCase
@end

@implementation TrendsTest
-(void)setUp{
    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2021-01-08"].date];
    [TestHelpers loadFixtureFromJSONFileNamed:@"blown_out_russian"];
    
}
-(void)testScrolling{
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Russian Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Trends"];
    [tester waitForTimeInterval:10000];
}
@end
