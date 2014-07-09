#import "Habit.h"
#import "TestHelpers.h"
#import "TimeHelper.h"
#import "ChainAnalysis.h"
#import "ChainBreak.h"
#import <OCMock.h>

@interface ChainAnalysis()
-(NSArray*)savedChainBreaks;
@end

SpecBegin(ChainBreakTests)
describe(@"Habit", ^{
    it(@"should correctly report next day required", ^{
        Habit * habit = [TestHelpers habit:@{@"active":@YES ,                // 01   02   03    04
                                             @"daysRequired": @[@NO, @NO, @NO, @YES, @NO, @NO, @YES] // needed wed and sat
                                             }];
        [habit checkDays:[TestHelpers days:@[@"2014-01-01"]]];
         expect([habit nextDayRequiredAfter:d(@"2014-01-02")]).to.equal(d(@"2014-01-04"));
    });
});
describe(@"Chain breaks", ^{
   
    describe(@"legacy detection", ^{
        it(@"should succeed", ^{
            Habit * habit = [TestHelpers habit:@{
                                                 @"title": @"Test habit",
                                                 @"active": @YES,
                                                 @"daysRequired":[TestHelpers everyDay],
                                                 @"identifier": @"testing"
                                                 }];
            [habit checkDays:[TestHelpers days: @[@"2014-01-01", @"2014-01-02", @"2014-01-09"]]];
            ChainAnalysis * analysis = [[ChainAnalysis alloc] initWithHabit:habit startDate:d(@"2014-01-01") endDate:d(@"2014-01-10") calculateImmediately:YES];
            expect(analysis.freshChainBreaks.count).to.equal(2);
            ChainBreak * firstBreak = analysis.freshChainBreaks.firstObject;
            expect(firstBreak.date).to.equal(d(@"2014-01-03"));
            expect(firstBreak.chainLength).to.equal(@2);
            ChainBreak * secondBreak = analysis.freshChainBreaks[1];
            expect(secondBreak.date).to.equal(d(@"2014-01-10"));
            expect(secondBreak.chainLength).to.equal(@1);
        });
        it(@"should work when habit is not required every day", ^{
            Habit * habit = [TestHelpers habit:@{
                                                 @"title": @"Test not every day habit",
                                                 @"active": @YES, //             //  01   02    03   04
                                                 @"daysRequired":@[@YES, @NO, @YES, @NO, @YES, @NO, @YES],
                                                 @"identifier": @"testing_not_every_day"
                                                 }];
            // 2014-01-01 is a Wednesday
            [habit checkDays:[TestHelpers days:@[@"2014-01-02", @"2014-01-04"]]]; // 2014-01-03 is not required
            ChainAnalysis * analysis = [[ChainAnalysis alloc] initWithHabit:habit startDate:d(@"2014-01-02") endDate:d(@"2014-01-04") calculateImmediately:YES];
            expect(analysis.freshChainBreaks.count).to.equal(0);
        });
        it(@"should not report saved chain breaks", ^{
            Habit * habit = [TestHelpers habit:@{
                                                 @"title": @"Habit with saved breaks",
                                                 @"active": @YES,
                                                 @"daysRequired": [TestHelpers everyDay],
                                                 @"identifier": @"saved_breaks"
                                                 }];
            [habit checkDays:[TestHelpers days:@[@"2014-01-01", @"2014-01-03"]]];
            OCMockObject * analysis = [OCMockObject partialMockForObject:[[ChainAnalysis alloc] initWithHabit:habit startDate:d(@"2014-01-01") endDate:d(@"2014-01-03") calculateImmediately:NO]];
            [[[analysis stub] andReturn:@[
                                          [[ChainBreak alloc] initWithDictionary:@{
                                                                                  @"habitIdentifier": habit.identifier,
                                                                                  @"date": d(@"2014-01-02")
                                                                                   } error:nil]
                                          ]] savedChainBreaks];
            [(ChainAnalysis*)analysis calculate];
            expect([(ChainAnalysis*)analysis freshChainBreaks].count).to.equal(0);
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