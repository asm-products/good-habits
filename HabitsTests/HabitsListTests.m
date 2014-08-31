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
//            [HabitsQueries overwriteHabits:@[]];
        });
        it(@"should show tip on plus arrow", ^{
            [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Paused habits"];
            
        });
        
    });
   
    describe(@"groupings", ^{
        beforeAll(^{
            [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2013-12-23"].date];
            [TestHelpers loadFixtureFromUserDefaultsNamed:@"list-tests.goodtohear.habits"];
        });
        beforeEach(^{
            if([UIAccessibilityElement accessibilityElement:nil view:nil withLabel:@"Dismiss" value:nil traits:UIAccessibilityTraitNone tappable:YES error:nil]){
                [tester tapViewWithAccessibilityLabel:@"Dismiss"];
            }
        });
        it(@"should show today's habits", ^{
            [tester waitForViewWithAccessibilityLabel:@"Monday 23 December"];
            [tester waitForViewWithAccessibilityLabel:@"Todo today"];
        });
        it(@"should show habits carried over from yesterday", ^{
            [tester waitForViewWithAccessibilityLabel:@"Carried over from yesterday"];
            [tester waitForViewWithAccessibilityLabel:@"Todo yesterday"];
        });
        it(@"should show habits not required today", ^{
            [tester waitForViewWithAccessibilityLabel:@"Not on Mondays"];
        });
        it(@"should show paused habits", ^{
            [tester waitForViewWithAccessibilityLabel:@"Paused habits"];
        });
        it(@"Should not show any duplicates", ^{
            UITableView * listTable = (UITableView*) [tester waitForViewWithAccessibilityLabel:@"Habits List"];
            expect([listTable numberOfRowsInSection:1]).to.equal(1);
            expect([listTable numberOfRowsInSection:2]).to.equal(1);
        });
    });
});
SpecEnd
