//
//  MigrationTests.m
//  Habits
//
//  Created by Michael Forrest on 23/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//
#import "PlistStoreToCoreDataMigrator.h"
#import "Habit.h"
#import "Chain.h"
#import "HabitDay.h"
#import "HabitsQueries.h"

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
        expect(chain.length).to.equal([@[@1,@5,@3, @2, @3][idx] intValue]);
    }];
 
}
@end
