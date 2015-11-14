//
//  MigrationTests.m
//  Habits
//
//  Created by Michael Forrest on 23/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//
#import "PlistStoreToCoreDataMigrator.h"

@interface MigrationTests : XCTestCase

@end

@implementation MigrationTests
-(void)testCorrectChainCountsDetected{
    // See testing_habits_expectation.png
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
    Habit * habit = [HabitsQueries findHabitByIdentifier:@"Testing habit"];
    expect(habit).notTo.beNil();
    expect(habit.chains.count).to.equal(5);
    [habit.sortedChains enumerateObjectsUsingBlock:^(Chain * chain, NSUInteger idx, BOOL *stop) {
        expect(chain.length).to.equal([@[@1,@5,@3, @2, @3, @0][idx] intValue]); // last number is because it sometimes crashes for some reason
    }];
 
}
-(void)testIdentifiersAreUnique{
    NSArray * source = @[
                         @{@"title": @"Thing"},
                         @{@"title": @"Thing"},
                         @{@"title": @"Thing"},
                         @{@"title": @"Other thing"}
                         ];
    NSArray * result = [PlistStoreToCoreDataMigrator useProperty:@"title" toPopulateUniqueIdentifierProperty:@"identifier" withArray:source];
    expect(result[0][@"identifier"]).to.equal(@"Thing");
    expect(result[1][@"identifier"]).to.equal(@"Thing.");
    expect(result[2][@"identifier"]).to.equal(@"Thing..");
    expect(result[3][@"identifier"]).to.equal(@"Other thing");
}
-(void)testMigrationAwayFrom_iCloud{
    // if migrating from < 2.1
    
    // alert user that iCloud has been discontinued (including an icon)
    
    // auto-migrate all data from most recently active data store
    
    // create a zip file of HabitsStore.sqlite and the contents of CoreDataUbiquitySupport if it exists
    
    // let the user know that if they have problems they can email this file to me with a description of their problem
}
@end
