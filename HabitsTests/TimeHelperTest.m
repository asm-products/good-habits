//
//  TimeHelperTest.m
//  Habits
//
//  Created by Michael Forrest on 12/10/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TimeHelper.h"
#import <YLMoment.h>
@interface TimeHelperTest : XCTestCase

@end

@implementation TimeHelperTest

- (void)testWeekdayIsCorrect {
    NSDate * date = [YLMoment momentWithDateAsString:@"2014-09-01"].date; // should be a Monday (1)
    expect([TimeHelper weekday:date]).to.equal(1);
}

@end
