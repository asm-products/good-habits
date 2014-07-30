#import "Habit.h"
#import "TestHelpers.h"
#import "TimeHelper.h"
#import <OCMock.h>
#import "HabitAnalysis.h"

SpecBegin(ChainBreakTests)
describe(@"Habit", ^{
    it(@"should correctly report next day required", ^{
        Habit * habit = [TestHelpers habit:@{@"active":@YES ,                // 01   02   03    04
                                             @"identifier": @"1",
                                             @"daysRequired": @[@NO, @NO, @NO, @YES, @NO, @NO, @YES] // needed wed and sat
                                             } daysChecked:@[@"2014-01-01"]];
         expect([habit nextDayRequiredAfter:d(@"2014-01-02")]).to.equal(d(@"2014-01-04"));
    });
});
describe(@"Chain breaks", ^{
    describe(@"legacy detection", ^{
        describe(@"success", ^{
            [TimeHelper selectDate:d(@"2014-01-09")];
            __block Habit * habit = [TestHelpers habit:@{
                                                 @"title": @"Test habit",
                                                 @"active": @YES,
                                                 @"daysRequired":[TestHelpers everyDay],
                                                 @"identifier": @"legacy"
                                                 } daysChecked:@[@"2014-01-01", @"2014-01-02", @"2014-01-09"]];
            it(@"should have padded out the days it needs to optimally perform the calculations ", ^{
                expect(habit.habitDays.count).to.equal(9);
            });
            it(@"should find the correct running totals", ^{
                expect([habit habitDayForKey:@"2014-01-01"].runningTotal).to.equal(@1);
                expect([habit habitDayForKey:@"2014-01-02"].runningTotal).to.equal(@2); // if this is @1 then it might be because the system thinks it's still "YES"
            });
            it(@"should correctly report chain breaks", ^{
                HabitAnalysis * analysis = [[HabitAnalysis alloc] initWithHabit:habit];
                expect(analysis.hasUnauditedChainBreaks).to.equal(YES);
                HabitDay * firstBreak = analysis.nextUnauditedDay;
                expect(firstBreak.date).to.equal(d(@"2014-01-03"));
                expect(firstBreak.runningTotalWhenChainBroken).to.equal(@2);
            });
            
        });
        it(@"should work when habit is not required every day", ^{
            [TimeHelper selectDate:[DayKeys dateFromKey:@"2014-01-04"]];
            Habit * habit = [TestHelpers habit:@{
                                                 @"title": @"Test not every day habit",
                                                 @"active": @YES, //             //  01   02    03   04
                                                 @"daysRequired":@[@YES, @NO, @YES, @NO, @YES, @NO, @YES],
                                                 @"identifier": @"testing_not_every_day"
                                                 } daysChecked:@[@"2014-01-02", @"2014-01-04"]];
            // 2014-01-01 is a Wednesday
            // 2014-01-03 is not required
            HabitAnalysis * analysis = [[HabitAnalysis alloc] initWithHabit:habit];
            expect(analysis.nextUnauditedDay).to.equal(nil);
        });
    });
    
    describe(@"breaks since last launch", ^{
        
    });
    
    describe(@"today", ^{
        
    });
    
    describe(@"chains confirmed unbroken", ^{
        it(@"should continue asking about days until now if chain wasn't broken", ^{
            
        });
    });
});

SpecEnd