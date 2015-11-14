//
//  PremiumFeatureTests.m
//  Habits
//
//  Created by Michael Forrest on 04/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF.h>
#import <OCMock.h>
#import "AppFeatures.h"
#import "TimeHelper.h"
@interface PremiumFeatureTests : XCTestCase

@end

@implementation PremiumFeatureTests

- (void)setUp
{
    [super setUp];
    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2014-08-22"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
}

- (void)testLockedTextField
{
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
//    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Broken"];
    OCMockObject * mockClass = [OCMockObject mockForClass:[AppFeatures class]];
    [[[mockClass stub] andReturnValue:@NO] statsEnabled];
    
    [tester tapViewWithAccessibilityLabel:@"" value:@"Missed today. What happened?" traits:UIAccessibilityTraitNone];
   
    [tester waitForViewWithAccessibilityLabel:@"Don't ask me again"];
    [tester tapViewWithAccessibilityLabel:@"Not now, thanks"];
    
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Don't ask me again"];
}

@end
