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

@interface HabitsListTests : XCTestCase

@end

@implementation HabitsListTests
-(void)testFirstUse{
    [HabitsQueries deleteAllHabits];
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Paused habits"];
}
-(void)testGroupings{
    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2013-12-23"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"list-tests.goodtohear.habits"];
    if([UIAccessibilityElement accessibilityElement:nil view:nil withLabel:@"Dismiss" value:nil traits:UIAccessibilityTraitNone tappable:YES error:nil]){
        [tester tapViewWithAccessibilityLabel:@"Dismiss"];
    }
    [tester waitForViewWithAccessibilityLabel:@"Monday 23 December"];
    [tester waitForViewWithAccessibilityLabel:@"Todo today"];
    [tester waitForViewWithAccessibilityLabel:@"Checkbox for Done today Checked"];
    [tester waitForViewWithAccessibilityLabel:@"Carried over from yesterday"];
    [tester waitForViewWithAccessibilityLabel:@"Todo yesterday"];
    [tester waitForViewWithAccessibilityLabel:@"Not on Mondays"];
    [tester waitForViewWithAccessibilityLabel:@"Todo other days"];
    [tester waitForViewWithAccessibilityLabel:@"Paused habits"];
    UITableView * listTable = (UITableView*) [tester waitForViewWithAccessibilityLabel:@"Habits List"];
    expect([listTable numberOfRowsInSection:1]).to.equal(1);
    expect([listTable numberOfRowsInSection:2]).to.equal(1);
}
-(void)testLongHabitName{
    [tester tapViewWithAccessibilityLabel:@"add"];
    [tester enterTextIntoCurrentFirstResponder:@"Lorem ipsum Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. \n"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    
}
@end

