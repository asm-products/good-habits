//
//  PremiumFeatureTests.m
//  Habits
//
//  Created by Michael Forrest on 04/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TimeHelper.h"
#import <YLMoment.h>
#import <KIF.h>
#import <OCMock.h>
#import "AppFeatures.h"
@interface PremiumFeatureTests : XCTestCase

@end

@implementation PremiumFeatureTests

- (void)setUp
{
    [super setUp];
    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-08-22"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
}

- (void)testLockedTextField
{
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
//    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Broken"];
    OCMockObject * mockClass = [OCMockObject mockForClass:[AppFeatures class]];
    [[[mockClass stub] andReturnValue:@NO] statsEnabled];
    
    [tester tapViewWithAccessibilityLabel:@"" value:@"What happened?" traits:UIAccessibilityTraitNone];
   
    [tester waitForViewWithAccessibilityLabel:@"Never ask again"];
    [tester tapViewWithAccessibilityLabel:@"Not now, thanks"];
    
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Never ask again"];
    [tester waitForTimeInterval:1000];
}

@end
