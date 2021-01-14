#import "Habit.h"
#import <YLMoment.h>
#import "HabitsCommon.h"
#import "Colors.h"
#import "TestHelpers.h"
#import "LegacyJSONImporter.h"
#import "HabitsQueries.h"
#import "JSONConversion.h"
#import "Chain.h"
#import "HabitDay.h"
#import <KIF.h>
#import "TimeHelper.h"
@interface JSONConversionTests : KIFTestCase

@end

@implementation JSONConversionTests
-(void)testReadingLegacyJSON{
    [TestHelpers deleteAllData];
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"habits_data_legacy" ofType:@"json"];
    NSArray * json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    
    [LegacyJSONImporter performMigrationWithArray:json];
    [HabitsQueries refresh];
    
    Habit * habit = [HabitsQueries findHabitByIdentifier:@"Drums"];
    
    
    expect(habit.title).to.equal(@"Drums");
    expect(habit.createdAt).to.equal([YLMoment momentWithDateAsString:@"2012-08-10 20:53:42 +0100"].date);
//    expect(habit.color).to.equal([Colors green]);
    expect(habit.daysRequired).to.equal(@[@YES,@YES,@YES,@YES,@YES,@YES,@YES]);
    NSLog(@"days required: %@", habit.daysRequired);
    //        expect(habit.daysChecked.count).to.equal(33);
    expect(habit.reminderTime.hour).to.equal(11);
    expect(habit.reminderTime.minute).to.equal(0);
}
-(void)testWritingJSON{
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
    
    NSArray * everything = [JSONConversion allHabitsAsJSONWithClient:[CoreDataClient defaultClient]];
    NSDictionary * json = everything.firstObject;

    expect(json[@"title"]).to.equal(@"Testing habit");
    expect(json[@"identifier"]).to.equal(@"Testing habit");
    expect(json[@"order"]).to.equal(@24);
    expect(json[@"createdAt"]).to.equal(@"2014-08-23 16:49:44 +0000"); // DaysKeys helper always creates dates in the current time zone. This test will break in different time zones for now.
    expect(json.allKeys.count).to.equal(9);
    expect(json[@"color"]).to.equal(@"#D28895");
    expect(json[@"daysRequired"]).to.equal(@[@"Sun",@"Mon",@"Tue",@"Thu",@"Fri",@"Sat"]);
    expect([json[@"chains"] count]).to.equal(5);
    NSDictionary *firstChain = json[@"chains"][0];
    expect(firstChain[@"days"][0][@"date"]).to.equal(@"2014-08-01 00:00:00 +0000");
    expect(firstChain[@"days"][0][@"runningTotal"]).to.equal(1);
}
-(void)testReadingJSON{
    [TestHelpers deleteAllData];
    NSString * path = [[NSBundle bundleForClass:[self class]] pathForResource:@"habits_data" ofType:@"json"];
    NSArray * json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    [JSONConversion performImportWithArray:json];
    Habit * habit = [HabitsQueries findHabitByIdentifier:@"Vocal exercises"];
    expect(habit.title).to.equal(@"Vocal exercises");
    expect(habit.order).to.equal(1);
    expect(habit.createdAt).to.equal([[TimeHelper jsonDateFormatter] dateFromString:@"2012-08-10 19:58:33 +0000"]);
    expect(habit.chains.count).to.equal(16);
    Chain * firstChain = habit.sortedChains.firstObject;
    expect(firstChain.days.count).to.equal(8);
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil];
    [tester waitForViewWithAccessibilityLabel:@"Vocal exercises"];
    
}
-(void)testOpeningUrlForLegacyJSON{
    [TestHelpers deleteAllData];
    [TestHelpers launchApplicationWithURLContainingDataFromFixture:@"habits_data_legacy"];
    [tester tapViewWithAccessibilityLabel:@"Restore Data"];
    
    [tester waitForViewWithAccessibilityLabel:@"Pull ups"];
}
-(void)testOpeningUrlForJSON{
    [TestHelpers deleteAllData];
    [TestHelpers launchApplicationWithURLContainingDataFromFixture:@"habits_data"];
    [tester tapViewWithAccessibilityLabel:@"Restore Data"];
    [tester waitForViewWithAccessibilityLabel:@"Pull ups"];
}

@end
