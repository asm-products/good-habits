//
//  AuditingFlowTests.m
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF.h>
#import <OCMock.h>
#import "HabitsList.h"
#import "TestHelpers.h"
#import "TimeHelper.h"
#import <UIAccessibilityElement-KIFAdditions.h>
@interface AuditingFlowTests : KIFTestCase
-(NSString*)didYouBreakTheChain;
@end

@implementation AuditingFlowTests
-(void)beforeAll{

    OCMStub([[OCMockObject mockForClass:[HabitsList class]] saveAll]);
    [TimeHelper selectDate:d(@"2014-01-03")];
    [HabitsList overwriteHabits:@[
                                  [TestHelpers habit:@{@"title": @"First",@"identifier": @"first", @"daysRequired": [TestHelpers everyDay], @"active": @YES,
                                                       @"daysChecked": @{@"2014-01-01": @YES}.mutableCopy }]
                                  ]];
}
-(void)testShouldNotShowAuditScreenWhenNotNeeded{
    [TimeHelper selectDate:d(@"2014-01-01")];
    [self applicationBecameActive];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:self.didYouBreakTheChain];
    
}
-(void)testReceivingLocalNotificationWhileAppIsRunning{
   // should pop up the audit thing
}
-(void)testCanDismissAtAnyTime{
    // cancel button should be wired up
    
}
-(void)testWhenAppLaunchedAndNeedsAuditingForYesterday{
    //
    [TimeHelper selectDate:d(@"2014-01-03")];
    [self applicationBecameActive];
    [tester waitForViewWithAccessibilityLabel:self.didYouBreakTheChain];
    [tester waitForViewWithAccessibilityLabel:@"1 day"];
    [tester waitForViewWithAccessibilityLabel:@"Yesterday - Thursday 2 Jan"];
    [tester tapViewWithAccessibilityLabel:@"I DID THIS"];
//    [tester tapViewWithAccessibilityLabel:@"Dismiss"];
    [tester waitForViewWithAccessibilityLabel:@"Checkbox for First Not checked"];
}
#pragma mark - Helpers
-(void)applicationBecameActive{
    [[[UIApplication sharedApplication] delegate] applicationDidBecomeActive:[UIApplication sharedApplication]];
}
-(NSString *)didYouBreakTheChain{
    return @"Did you break the chain?";
}
@end
