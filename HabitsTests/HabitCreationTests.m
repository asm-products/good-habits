#import <KIF.h>
#import "TimeHelper.h"

@interface HabitCreationTests : KIFTestCase

@end


@implementation HabitCreationTests
-(void)testAddingNewHabit{
    [TimeHelper selectDate:[Moment momentWithDateAsString:@"2014-01-01"].date];
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
    expect(habit.chains.count).to.equal(0);
    
    [tester tapViewWithAccessibilityLabel:@"Delete this habit"];
    [tester tapViewWithAccessibilityLabel:@"Delete"];
}
@end
