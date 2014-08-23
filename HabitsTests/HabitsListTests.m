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
#import "HabitsQueries.h"
#import "Colors.h"
#import "Calendar.h"
#import <NSArray+F.h>
#import "TimeHelper.h"
#import <YLMoment.h>
#import "TestHelpers.h"
#import <UIAccessibilityElement-KIFAdditions.h>
Habit * habit(NSDictionary*dict, NSArray * daysChecked){
    return [TestHelpers habit:dict daysChecked:daysChecked];
}
NSMutableArray * everyDay(){
    return [TestHelpers everyDay];
}

SpecBegin(HabitsListTests)
describe(@"list", ^{
    describe(@"first use", ^{
        beforeAll(^{
            [HabitsQueries overwriteHabits:@[]];
        });
        it(@"should show tip on plus arrow", ^{
            [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Paused habits"];
            
        });
        
    });
   
    describe(@"groupings", ^{
        beforeAll(^{
            [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-01-01"].date];
            
            [HabitsQueries overwriteHabits:@[
                                          habit(@{@"title": @"Todo today", @"active":@YES, @"color":[Colors green], @"daysRequired":everyDay(),@"identifier":@"1"},nil),
                                          habit(@{@"title": @"Todo yesterday", @"active":@YES, @"color":[Colors green], @"daysRequired":@[@YES, @NO, @NO, @NO, @NO, @NO, @NO].mutableCopy , @"identifier":@"2"} ,nil),
                                          habit(@{@"title": @"Todo other days", @"active":@YES, @"color":[Colors green], @"daysRequired":@[@NO,@NO,@YES,@NO,@NO,@NO,@NO].mutableCopy, @"identifier": @"3"},@[@"2013-12-31"]),
                                          habit(@{@"title": @"Todo some other time", @"active":@NO, @"color":[Colors green], @"identifier":@"4"}, nil)
                                          ]];
        });
        beforeEach(^{
            if([UIAccessibilityElement accessibilityElement:nil view:nil withLabel:@"Dismiss" value:nil traits:UIAccessibilityTraitNone tappable:YES error:nil]){
                [tester tapViewWithAccessibilityLabel:@"Dismiss"];
            }
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
