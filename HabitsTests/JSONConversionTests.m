#import "Habit.h"
#import <YLMoment.h>
#import "TimeHelper.h"
#import "Colors.h"
#import "TestHelpers.h"
#import "LegacyJSONImporter.h"
#import "HabitsQueries.h"
#import "JSONConversion.h"
@interface JSONConversionTests : XCTestCase

@end

@implementation JSONConversionTests
-(void)testReadingLegacyJSON{
    [TestHelpers deleteAllData];
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"habits_data_lots" ofType:@"json"];
    NSArray * json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    
    [LegacyJSONImporter performMigrationWithArray:json];
    [HabitsQueries refresh];
    
    Habit * habit = [HabitsQueries findHabitByIdentifier:@"Drums"];
    
    
    expect(habit.title).to.equal(@"Drums");
    expect(habit.createdAt).to.equal([YLMoment momentWithDateAsString:@"2012-08-10 20:53:42 +0100"].date);
    expect(habit.color).to.equal([Colors green]);
    expect(habit.daysRequired).to.equal(@[@YES,@YES,@YES,@YES,@YES,@YES,@YES]);
    NSLog(@"days required: %@", habit.daysRequired);
    //        expect(habit.daysChecked.count).to.equal(33);
    expect(habit.reminderTime.hour).to.equal(11);
    expect(habit.reminderTime.minute).to.equal(0);
}
-(void)testWritingJSON{
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
    
    NSArray * everything = [JSONConversion allHabitsAsJSON];
    NSDictionary * json = everything.firstObject;
    
//        [TimeHelper selectDate:d(@"2014-01-02")];
//        [DayKeys clearDateKeysCache];
//        habit = [[Habit alloc] initWithDictionary:@{
//                                                    @"title": @"Title",
//                                                    @"order": @1,
//                                                    @"identifier": @"123",
//                                                    @"createdAt": [DayKeys dateFromKey:@"2014-01-01"],
//                                                    @"color": [Colors blue],
//                                                    @"daysRequired": [TestHelpers everyDay],
//                                                    @"reminderTime": [TimeHelper dateComponentsForHour:14 minute:45]
//                                                    } error:nil];
//        [habit checkDays:@[@"2014-01-01", @"2014-01-02"]];
//        json = [MTLJSONAdapter JSONDictionaryFromModel:habit];

    expect(json[@"title"]).to.equal(@"Title");
    expect(json[@"id"]).to.equal(@"123");
    expect(json[@"order"]).to.equal(@1);
    expect(json[@"created_at"]).to.equal(@"2014-01-01 00:00:00 +0100"); // DaysKeys helper always creates dates in the current time zone. This test will break in different time zones for now.
    expect(json.allKeys.count).to.equal(10);
    expect(json[@"latestAnalysis"]).to.beNil();
    expect(json[@"color"]).to.equal(@"#488FB4");
    expect(json[@"days_required"]).to.equal(@[@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat"]);
    expect(json[@"days_checked"]).to.equal([NSNull null]);
    expect([json[@"days"] count]).to.equal(2);
    NSDictionary *first = json[@"days"][0];
    expect(first[@"day"]).to.equal(@"2014-01-01");
    expect(first[@"running_total"]).to.equal(1);
    NSDictionary * second = json[@"days"][1];
    expect(second[@"day"]).to.equal(@"2014-01-02");
    expect(second[@"running_total"]).to.equal(2);
    expect(json[@"time_to_do"]).to.equal(@"14:45");
    
}
-(void)testReadingJSON{
    
}

@end
