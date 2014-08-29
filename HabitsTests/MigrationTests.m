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
SpecBegin(MigrationTests)

describe(@"upgrade expectations", ^{
    it(@"should detect the correct number of chains", ^{
        // See testing_habits_expectation.png
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"testing.goodtohear.habits" ofType:@"plist"]];
        NSArray * array = [dict valueForKeyPath:@"goodtohear.habits_habits"];
        [PlistStoreToCoreDataMigrator performMigrationWithArray:array progress:^(float progress) {
        }];
        Habit * habit = [HabitsQueries findHabitByIdentifier:@"Testing habit"];
        expect(habit).notTo.beNil();
        expect(habit.chains.count).to.equal(5);
        [habit.sortedChains enumerateObjectsUsingBlock:^(Chain * chain, NSUInteger idx, BOOL *stop) {
            expect(chain.length).to.equal([@[@1,@5,@3, @2, @3][idx] intValue]);
        }];
        NSLog(@"Chains: %@", [habit.sortedChains valueForKeyPath:@"days.date"]);
    });
});
SpecEnd
