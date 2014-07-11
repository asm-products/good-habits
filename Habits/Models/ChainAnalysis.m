//
//  ChainAnalysis.m
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ChainAnalysis.h"
#import "TimeHelper.h"
#import "ChainBreak.h"
#import "CoreDataClient.h"
#import <NSArray+F.h>
#import "HabitsList.h"
#import "Audits.h"

@implementation ChainAnalysis
-(instancetype)initWithHabit:(Habit *)habit startDate:(NSDate *)startDate endDate:(NSDate *)endDate calculateImmediately:(BOOL)shouldCalculateImmediately{
    if(self = [super init]){
        self.habit = habit;
        self.startDate = startDate;
        self.endDate = endDate;
        if(shouldCalculateImmediately) [self calculate];
    }
    return self;
}
-(void)calculate{
    NSAssert(self.habit.identifier != nil, @"requires a habit identifier!");
    NSMutableArray * chainBreaks = [NSMutableArray new];
    NSDate * date = self.startDate;
    BOOL inUnbrokenChain = YES;
    BOOL itIsAuditingTime = [[TimeHelper dateForTimeToday:[Audits scheduledTime]] isBefore:[TimeHelper now]];
    while ([date isBefore:self.endDate]) {
        if(([date isEqual:[TimeHelper now].beginningOfDay] && itIsAuditingTime == NO) || [self.habit continuesActivityAfter:date]) {
            inUnbrokenChain = YES;
        }else{
            if(inUnbrokenChain){
                // we got a broken chain
                
                NSNumber * chainLength = [self.habit chainLengthOnDate:date];
                NSLog(@"Chain length of %@  %@ = %@ - chain = %@", self.habit.title, date, chainLength, self.habit.daysChecked);
                ChainBreak * chainBreak = [[ChainBreak alloc] initWithDictionary:@{
                                                                                   @"habitIdentifier": self.habit.identifier,
                                                                                   @"date": [self.habit nextDayRequiredAfter: date],
                                                                                   @"status": @"detected",
                                                                                   @"chainLength": chainLength ? chainLength : [NSNull null]
                                                                                   } error:nil];
                [chainBreaks addObject:chainBreak];
                inUnbrokenChain = NO;
            }else{
                // accounted for by previous chain break
            }
        }
        date = [TimeHelper addDays:1 toDate:date];
    }
    
    self.freshChainBreaks = [self findFreshChainBreaks: chainBreaks];
    for (ChainBreak * chainBreak in self.freshChainBreaks) {
        [MTLManagedObjectAdapter managedObjectFromModel:chainBreak insertingIntoContext:[HabitsList coreDataClient].managedObjectContext error:nil];
    }
}
-(NSArray*)findFreshChainBreaks:(NSArray*)chainBreaks{
    self.savedChainBreaks = [self loadChainBreaks];
    return [chainBreaks filter:^BOOL(ChainBreak * chainBreak) {
        return [self.savedChainBreaks indexOfObjectPassingTest:^BOOL(ChainBreak * savedChainBreak, NSUInteger idx, BOOL *stop) {
            return [savedChainBreak.date isEqualToDate:chainBreak.date];
        }] == NSNotFound;
    }];
    
}
-(NSArray*)loadChainBreaks{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"ChainBreak"];
    request.predicate = [NSPredicate predicateWithFormat:@"(date >= %@ AND  date <= %@) AND (habitIdentifier = %@)", self.startDate, self.endDate, self.habit.identifier];
    CoreDataClient * client = [HabitsList coreDataClient];
    NSError * error;
    NSArray * managedObjects = [client.managedObjectContext executeFetchRequest:request error:&error];
    return [managedObjects map:^id(NSManagedObject* obj) {
        NSError * mtlError;
        return [MTLManagedObjectAdapter modelOfClass:[ChainBreak class] fromManagedObject:obj error:&mtlError];
    }];
}
-(NSArray *)allChainBreaks{
    return [self loadChainBreaks];
}
@end
