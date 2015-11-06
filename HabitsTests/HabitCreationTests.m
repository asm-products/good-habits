#import <KIF.h>
#import "TimeHelper.h"
#import <YLMoment.h>
#import "Habit.h"
#import "HabitsQueries.h"

@interface HabitCreationTests : XCTestCase

@end


@implementation HabitCreationTests
-(void)testAddingNewHabit{
    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-01-01"].date];
    [tester tapViewWithAccessibilityLabel:@"add"];
    [tester enterTextIntoCurrentFirstResponder:@"Floss\n"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    
    [tester waitForViewWithAccessibilityLabel:@"Wednesday 1 January"];
    
    [tester tapViewWithAccessibilityLabel:@"Floss"]; // Florida?
    
    Habit * habit = [HabitsQueries findHabitByTitle:@"Floss"];
    expect(habit.chains.count).to.equal(1);
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForViewWithAccessibilityLabel:@"Wednesday 1 January"];
    [tester tapViewWithAccessibilityLabel:@"Floss"];
    expect(habit.chains.count).to.equal(1);
    
    [tester tapViewWithAccessibilityLabel:@"Delete this habit"];
    [tester tapViewWithAccessibilityLabel:@"Delete"];
}
@end
