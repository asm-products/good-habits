//
//  ReminderTests.m
//  Habits
//
//  Created by Michael Forrest on 01/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF.h>
@interface ReminderTests : XCTestCase

@end

@implementation ReminderTests

- (void)testTimePresentation
{
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
    [tester tapViewWithAccessibilityLabel:@"Testing habit"];
    [tester waitForViewWithAccessibilityLabel:@"Remind at 8:30 AM"];
}

@end
