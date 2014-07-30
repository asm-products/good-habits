#import "DayKeys.h"
SpecBegin(DateKeysSpec)

describe(@"Date keys helper", ^{
    it(@"should pad out days as expected", ^{
        [DayKeys clearDateKeysCache];
        NSArray * keys = [DayKeys dateKeysIncluding:@"2014-01-01" last:@"2014-02-01" forwardPadding:0];
        expect(keys.count).to.equal(32);
        expect([keys indexOfObject:@"2014-01-23"]).toNot.equal(NSNotFound);
    });
});

SpecEnd
