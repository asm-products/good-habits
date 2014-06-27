//
//  HabitsListTests.m
//  Habits
//
//  Created by Michael Forrest on 26/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <KIF.h>
#import <OCMock.h>
#import "Habit.h"
#import "HabitsList.h"
#import "Colors.h"
#import "Calendar.h"
#import <NSArray+F.h>
#import "TimeHelper.h"
#import <YLMoment.h>

Habit * habit(NSDictionary*dict){
    NSError * error;
    Habit * result = [[Habit alloc] initWithDictionary:dict error:&error];
    if(error) @throw [NSException exceptionWithName:@"Bad habit error" reason:error.localizedDescription userInfo:@{@"error":error}];
    return result;
}
NSMutableArray * everyDay(){
    return [[Calendar days] map:^id(id obj) {
        return @YES;
    }].mutableCopy;
}

SpecBegin(HabitsListTests)
describe(@"list", ^{
    describe(@"first use", ^{
        beforeAll(^{
            [HabitsList overwriteHabits:@[]];
        });
        it(@"should show tip on plus arrow", ^{
            [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Paused habits"];
            
        });
        
    });
   
    describe(@"groupings", ^{
        beforeAll(^{
            [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-01-01"].date];
            
            [HabitsList overwriteHabits:@[
                                          habit(@{@"title": @"Todo today", @"active":@YES, @"color":[Colors green], @"daysRequired":everyDay()}),
                                          habit(@{@"title": @"Todo yesterday", @"active":@YES, @"color":[Colors green], @"daysRequired":@[@YES, @NO, @NO, @NO, @NO, @NO, @NO].mutableCopy  } ),
                                          habit(@{@"title": @"Todo other days", @"active":@YES, @"color":[Colors green], @"daysRequired":@[@NO,@NO,@YES,@NO,@NO,@NO,@NO].mutableCopy, @"daysChecked": @{@"2013-12-31": @YES}.mutableCopy}),
                                          habit(@{@"title": @"Todo some other time", @"active":@NO, @"color":[Colors green]})
                                          ]];
        });
        it(@"should show today's habits", ^{
            [tester waitForViewWithAccessibilityLabel:@"Wednesday 1 January"];
            [tester waitForViewWithAccessibilityLabel:@"Todo today"];
        });
        it(@"should show habits carried over from yesterday", ^{
            [tester waitForViewWithAccessibilityLabel:@"Carried over from yesterday"];
            [tester waitForViewWithAccessibilityLabel:@"Todo yesterday"];
        });
        it(@"should show habits not required today", ^{
            [tester waitForViewWithAccessibilityLabel:@"Not on Wednesdays"];
        });
        it(@"should show paused habits", ^{
            [tester waitForViewWithAccessibilityLabel:@"Paused habits"];
        });
    });
});
SpecEnd
