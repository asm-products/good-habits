//
//  JSONImportTests.m
//  Habits
//
//  Created by Michael Forrest on 29/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//
#import <Mantle.h>
#import "Habit.h"
#import <YLMoment.h>
#import "Colors.h"
SpecBegin(JSONImport)

describe(@"legacy format", ^{
    __block Habit * habit;
    beforeAll(^{
        NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"habits_data_lots" ofType:@"json"];
        NSArray * json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
        habit = [MTLJSONAdapter modelOfClass:[Habit class] fromJSONDictionary:json.firstObject error:nil];
    });
    it(@"should do the basics", ^{
        expect(habit.title).to.equal(@"Drums");
        expect(habit.createdAt).to.equal([YLMoment momentWithDateAsString:@"2012-08-10 20:53:42 +0100"].date);
    });
    it(@"should do colours", ^{
        expect(habit.color).to.equal([Colors green]);
    });
    it(@"should do days required", ^{});
    it(@"should do days checked", ^{});
    it(@"should do reminder time", ^{});
});

SpecEnd