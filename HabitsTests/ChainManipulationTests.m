#import <KIF.h>
#import <YLMoment.h>
#import "TimeHelper.h"
SpecBegin(ChainManipulationTests)

describe(@"chain manipulations", ^{
   describe(@"Checking today", ^{
       it(@"Should correctly update the chains when checking today", ^{
           [TimeHelper selectDate:[YLMoment momentWithDateAsString:@"2014-08-22"].date];
           [TestHelpers loadFixtureFromUserDefaultsNamed:@"testing.goodtohear.habits"];
           [tester waitForViewWithAccessibilityLabel:@"3"]; // current chain length
           [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Not checked"];
           [tester waitForViewWithAccessibilityLabel:@"4"];
           [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Checked"];
           [tester waitForViewWithAccessibilityLabel:@"3"];
           [tester tapViewWithAccessibilityLabel:@"Checkbox for Testing habit Broken"];
           [tester tapViewWithAccessibilityLabel:@"Testing habit"];
           [tester waitForViewWithAccessibilityLabel:@"21 August, last in chain"];
           [tester tapViewWithAccessibilityLabel:@"22 August"];
           [tester waitForViewWithAccessibilityLabel:@"22 August, last in chain"];
           [tester waitForTimeInterval:100];
       });
   });
});

SpecEnd
