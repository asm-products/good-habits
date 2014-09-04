#import <KIF.h>
#import <YLMoment.h>
#import "TimeHelper.h"
#import "Habit.h"
#import "HabitsQueries.h"
@interface ChainManipulationTests : XCTestCase
@end
@implementation ChainManipulationTests
-(void)setUp{
    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-08-22"].date];
    [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
    
}
-(void)testChainManipulations{
    
    Habit * habit = [HabitsQueries findHabitByIdentifier:@"Testing habit"];
    
    // List: toggle today
    [tester waitForViewWithAccessibilityLabel:@"3"]; // current chain length
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
    [tester waitForViewWithAccessibilityLabel:@"4"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
    [tester waitForViewWithAccessibilityLabel:@"3"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Broken"];
    
    // Calendar: toggle today
    [tester tapViewWithAccessibilityLabel:@"Testing habit"];
    expect(habit.chains.count).to.equal(5);
    
    [tester waitForViewWithAccessibilityLabel:@"21 August, last in chain"];
    [tester tapViewWithAccessibilityLabel:@"22 August"];
    expect(habit.chains.count).to.equal(5);
    [tester tapViewWithAccessibilityLabel:@"22 August, last in chain"];
    [tester waitForViewWithAccessibilityLabel:@"22 August"];
    expect(habit.chains.count).to.equal(5);
    
    // Mid chain: toggle today
    [tester tapViewWithAccessibilityLabel:@"11 August, mid-chain"];
    expect(habit.chains.count).to.equal(6);
    [tester waitForViewWithAccessibilityLabel:@"10 August, isolated day"];
    [tester waitForViewWithAccessibilityLabel:@"12 August, isolated day"];
    [tester tapViewWithAccessibilityLabel:@"11 August"];
    expect(habit.chains.count).to.equal(5);
    
    [tester waitForViewWithAccessibilityLabel:@"11 August, mid-chain"];
    [tester tapViewWithAccessibilityLabel:@"12 August, last in chain"];
    expect(habit.chains.count).to.equal(5);
    
    // Make sure we don't get a weird gap in a re-joined chain
    [tester tapViewWithAccessibilityLabel:@"19 August, mid-chain"];
    expect(habit.chains.count).to.equal(6);
    [tester tapViewWithAccessibilityLabel:@"20 August"];
    expect(habit.chains.count).to.equal(6);
    [tester waitForViewWithAccessibilityLabel:@"19 August"];
    [tester waitForViewWithAccessibilityLabel:@"20 August, first in chain"];
    
    // Make sure toggling a single day works
    [tester tapViewWithAccessibilityLabel:@"1 August, isolated day"];
    expect(habit.chains.count).to.equal(5);
    [tester tapViewWithAccessibilityLabel:@"1 August"];
    expect(habit.chains.count).to.equal(6);
    [tester waitForViewWithAccessibilityLabel:@"1 August, isolated day"];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
}
-(void)testNewChainCreatedByTickingToday{
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Another testing habit Not checked"];
    [tester waitForViewWithAccessibilityLabel:@"Current chain length 1, longest chain 1"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Another testing habit Checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Another testing habit Broken"];
    [tester waitForViewWithAccessibilityLabel:@"Checkbox for Another testing habit Not checked"];
}
-(void)testChangingRequiredDatesDoesNotRuinExistingChain{
    [tester tapViewWithAccessibilityLabel:@"Testing habit"];
    [tester tapViewWithAccessibilityLabel:@"Wed required? No"];
    [tester waitForViewWithAccessibilityLabel:@"Wed required? Yes"];
    [tester waitForViewWithAccessibilityLabel:@"20 August"];
    [tester tapViewWithAccessibilityLabel:@"19 August, mid-chain"];
    [tester waitForViewWithAccessibilityLabel:@"21 August, isolated day"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
}
@end
