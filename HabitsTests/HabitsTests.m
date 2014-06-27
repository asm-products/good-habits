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
NSDate * d(NSString* key){
    return [Habit dateFromString:key];
}

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
});
SpecEnd