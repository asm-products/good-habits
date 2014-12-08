#import <KIF.h>
#import <YLMoment.h>
#import "TimeHelper.h"
#import "Habit.h"
#import "HabitsQueries.h"
#import <OCMock.h>
#import "AppFeatures.h"
@interface ChainManipulationTests : XCTestCase
@end
@implementation ChainManipulationTests
-(void)setUp{
    OCMockObject * mockClass = [OCMockObject mockForClass:[AppFeatures class]];
    [[[mockClass stub] andReturnValue:@YES] statsEnabled];
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
    
    
    [tester tapViewWithAccessibilityLabel:@"3 August"];
    [tester waitForViewWithAccessibilityLabel:@"3 August, first in chain"];
    
    [tester tapViewWithAccessibilityLabel:@"Back"];
}
-(void)testNewChainCreatedByTickingToday{
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Another testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Record length at 1 day"];
    [tester waitForViewWithAccessibilityLabel:@"Current length: 1 day\nLongest chain: 1 day"];
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
-(void)testCanExplicitlyBreakTwoChainsInSequence{
    
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
    [tester tapViewWithAccessibilityLabel:@"" value:@"Missed today. What happened?" traits:UIAccessibilityTraitNone];
    [tester enterTextIntoCurrentFirstResponder:@"I messed it up. Sorry.\n"];
    [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-08-23"].date];
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH object:nil];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"I messed it up. Sorry."];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
    [tester tapViewWithAccessibilityLabel:@"" value:@"Missed today. What happened?" traits:UIAccessibilityTraitNone];
    [tester enterTextIntoCurrentFirstResponder:@"Oh no, not again\n"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Broken"];

}
-(void)testPastChainsAreNotExplicitlyBroken{
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Another testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Another testing habit Checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Another testing habit Broken"];
    [tester waitForViewWithAccessibilityLabel:@"-20"];
}
-(void)testPastChainsShowChainBreakDateAndButtonToAddDay{
    [tester waitForViewWithAccessibilityLabel:@"Missed 20 days ago. What happened?"];
    [tester tapViewWithAccessibilityLabel:@"Broken at -20 days"];
    [tester tapViewWithAccessibilityLabel:@"✓ 20 days ago"];
    [tester waitForViewWithAccessibilityLabel:@"Broken at -19 days"];
    [tester tapViewWithAccessibilityLabel:@"" value: @"Missed 19 days ago. What happened?" traits:UIAccessibilityTraitNone];
    [tester waitForKeyboard];
    [tester waitForViewWithAccessibilityLabel:@"" value: @"Missed 19 days ago. What happened?" traits:UIAccessibilityTraitNone];
}

-(void)testThatOtherBug{
    [tester tapViewWithAccessibilityLabel:@"Testing habit"];
    [tester tapViewWithAccessibilityLabel:@"21 August, last in chain"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
    [tester waitForViewWithAccessibilityLabel:@"Checkbox for Testing habit Broken"];
    [tester tapViewWithAccessibilityLabel:@"Testing habit"];
    [tester tapViewWithAccessibilityLabel:@"20 August"];
    [tester tapViewWithAccessibilityLabel:@"21 August"];
//    [tester waitForTimeInterval:1000];
    [tester waitForViewWithAccessibilityLabel:@"20 August, mid-chain"];
    [tester waitForViewWithAccessibilityLabel:@"21 August, last in chain"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
}
-(void)testNewHabitChainManipulationWorks{
    [tester tapViewWithAccessibilityLabel:@"add"];
    [tester enterTextIntoCurrentFirstResponder:@"New one\n"];
    [tester tapViewWithAccessibilityLabel:@"18 August"];
    [tester tapViewWithAccessibilityLabel:@"19 August"];
    [tester tapViewWithAccessibilityLabel:@"20 August"];
    [tester waitForViewWithAccessibilityLabel:@"18 August, first in chain"];
    [tester waitForViewWithAccessibilityLabel:@"19 August, mid-chain"];
    [tester waitForViewWithAccessibilityLabel:@"20 August, last in chain"];
    
    [tester tapViewWithAccessibilityLabel:@"21 August"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    
    [tester tapViewWithAccessibilityLabel:@"Checkbox for New one Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for New one Checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for New one Broken"];
    
    [tester tapViewWithAccessibilityLabel:@"New one"];
    [tester tapViewWithAccessibilityLabel:@"Back"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Checkbox for New one Checked"];

    [tester tapViewWithAccessibilityLabel:@"New one"];
    [tester tapViewWithAccessibilityLabel:@"17 August"];
    [tester waitForViewWithAccessibilityLabel:@"17 August, first in chain"];
    
}
-(void)testTogglingAChainOnAndOffDoesNotRuinBadgeState{
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
    [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Broken"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Broken at 3 days"];
    [tester waitForViewWithAccessibilityLabel:@"Length at 3 days"];
}

@end
