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
    });
    it(@"should do days checked", ^{
        expect(habit.daysChecked.count).to.equal(33);
    });
    it(@"should do reminder time", ^{
        expect(habit.reminderTime.hour).to.equal(4);
        expect(habit.reminderTime.minute).to.equal(30);
    });
});

SpecEnd