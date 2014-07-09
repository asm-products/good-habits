//
//  HabitsTests.m
//  HabitsTests
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//
#import "Habit.h"
#import "TimeHelper.h"
#import <NSArray+F.h>
#import <YLMoment.h>
#import "TestHelpers.h"
SpecBegin(HabitsTest)
describe(@"chains", ^{
    it(@"should find continued chains correctly", ^{
        [TimeHelper selectDate:d(@"2014-01-01")];
        Habit * habit = [Habit new];
        [habit checkDays: [@[
                             @"2013-12-30",
                             @"2013-12-31",
                             @"2014-01-01"
                             ] map:^id(NSString * day) {
                                 return d(day);
                             }]];
        //        expect([habit continuesActivityAfter:d(@"2013-12-30")]).to.beTruthy(); //- not sure what I'm getting at here.
    });
    it(@"should pick up subchains", ^{
        __block Habit * habit;
        __block NSDate * day;
        before(^{
            day = [YLMoment momentWithDateAsString:@"2014-01-10"].date;
            habit = [[Habit alloc] initWithDictionary:@{} error:nil];
            [habit checkDays:@[
                               day,
                               [TimeHelper addDays:-3 toDate:day]
                               ]];
        });
        it(@"should register activity before", ^{
            expect([habit continuesActivityBefore:day]).to.equal(YES);
        });
        it(@"should not register activity after", ^{
            expect([habit continuesActivityAfter:day]).to.equal(NO);
        });
        it(@"should now register day after", ^{
            [habit checkDays:@[[TimeHelper addDays:3 toDate:day]]];
            expect([habit continuesActivityAfter:day]).to.equal(YES);
        });
    });
    it(@"should get normal subchains right", ^{
        Habit * habit = [[Habit alloc] initWithDictionary:@{@"active":@YES, @"reminderTime": [TimeHelper dateComponentsForHour:12 minute:0]} error:nil];
        NSDate * midday = [YLMoment momentWithDateAsString:@"2014-01-01 12:00"].date;
        [habit checkDays:@[midday]];
        expect([habit done:midday]).to.equal(YES);
    });
    it(@"should schedule reminders as expected", ^{
        Habit * habit = [[Habit alloc] initWithDictionary:@{@"reminderTime": [TimeHelper dateComponentsForHour:12 minute:0]} error:nil];
        [habit recalculateNotifications];
        expect(habit.notifications.count).to.equal(7);
    });
});

SpecEnd