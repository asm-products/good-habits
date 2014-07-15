#import <Mantle.h>
#import "Habit.h"
#import <YLMoment.h>
#import "TimeHelper.h"
#import "Colors.h"
#import "TestHelpers.h"
SpecBegin(JSONConversionTests)

describe(@"Reading JSON", ^{
    __block Habit * habit;
    beforeAll(^{
        NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"habits_data_lots" ofType:@"json"];
        NSArray * json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
        NSError * error;
        habit = [MTLJSONAdapter modelOfClass:[Habit class] fromJSONDictionary:json.firstObject error:&error];
        expect(error).to.beNil();
    });
    it(@"should do the basics", ^{
        expect(habit.title).to.equal(@"Drums");
        expect(habit.createdAt).to.equal([YLMoment momentWithDateAsString:@"2012-08-10 20:53:42 +0100"].date);
    });
    it(@"should do colours", ^{
        expect(habit.color).to.equal([Colors green]);
    });
    it(@"should do days required", ^{
        expect(habit.daysRequired).to.equal(@[@YES,@YES,@YES,@YES,@YES,@YES,@YES]);
        NSLog(@"days required: %@", habit.daysRequired);
    });
    it(@"should do days checked", ^{
        expect(habit.daysChecked.count).to.equal(33);
    });
    it(@"should do reminder time", ^{
        expect(habit.reminderTime.hour).to.equal(11);
        expect(habit.reminderTime.minute).to.equal(0);
    });
});

describe(@"Writing JSON", ^{
    __block Habit * habit;
    __block NSDictionary * json;
    beforeAll(^{
        habit = [[Habit alloc] initWithDictionary:@{
                                                    @"title": @"Title",
                                                    @"order": @1,
                                                    @"identifier": @"123",
                                                    @"createdAt": [Habit dateFromString:@"2014-01-01"],
                                                    @"color": [Colors blue],
                                                    @"daysRequired": @[@YES, @YES, @YES],
                                                    @"reminderTime": [TimeHelper dateComponentsForHour:14 minute:45]
                                                    } error:nil];
        [habit checkDays:@[d(@"2014-01-01"), d(@"2014-01-02")]];
        json = [MTLJSONAdapter JSONDictionaryFromModel:habit];
    });
    it(@"should do the basics", ^{
        expect(json[@"title"]).to.equal(@"Title");
        expect(json[@"id"]).to.equal(@"123");
        expect(json[@"order"]).to.equal(@1);
        expect(json[@"created_at"]).to.equal(@"2014-01-01 00:00:00 +0000");
    });
    it(@"should not include some data", ^{
        expect(json.allKeys.count).to.equal(9);
        expect(json[@"latestAnalysis"]).to.beNil();
    });
    it(@"should convert the colour", ^{
        expect(json[@"color"]).to.equal(@"#488FB4");
    });
    it(@"should do the days required", ^{
        expect(json[@"days_required"]).to.equal(@[@"Sun",@"Mon",@"Tue"]);
    });
    it(@"should do days checked", ^{
        expect(json[@"days_checked"]).to.equal(@{
                                                 @"2014-01-01":@1,
                                                 @"2014-01-02":@2
                                                 });
    });
    it(@"should do reminder time", ^{
        expect(json[@"time_to_do"]).to.equal(@"14:45");
    });
});

SpecEnd