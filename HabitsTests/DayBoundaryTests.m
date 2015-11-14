//
//  DayBoundaryTests.m
//  Habits
//
//  Created by Michael Forrest on 12/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KIF.h>
#import "TimeHelper.h"
@interface DayBoundaryTests : KIFTestCase
@end

@implementation DayBoundaryTests

-(void)testDayBoundaryInBerlinTimeZone{
    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2013-12-23 01:00:00 -0400"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"list-tests.goodtohear.habits"];
    expect([TimeHelper today]).to.equal([Moment momentWithDateAsString:@"2013-12-23 00:00:00 +0000"].date);
}

@end
