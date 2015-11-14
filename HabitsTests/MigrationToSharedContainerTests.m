//
//  MigrationToSharedContainerTests.m
//  Habits
//
//  Created by Michael Forrest on 14/11/2015.
//  Copyright © 2015 Good To Hear. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF.h>
#import "TimeHelper.h"
@interface MigrationToSharedContainerTests : XCTestCase

@end

@implementation MigrationToSharedContainerTests

-(void)setUp{
    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2014-08-22"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
}

@end
