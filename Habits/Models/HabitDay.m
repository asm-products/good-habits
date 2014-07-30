//
//  HabitDay.m
//  Habits
//
//  Created by Michael Forrest on 15/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitDay.h"
#import "Habit.h"
#import "DayKeys.h"
@implementation HabitDay
-(NSDate *)date{
    return [DayKeys dateFromKey:self.day];
}
-(void)confirmAndSave{
    
}
+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"habitIdentifier": @"habit_id",
             @"isChecked": @"checked",
             @"runningTotal": @"running_total",
             @"renderStatus": [NSNull null],
             @"chainBreakStatus": @"chain_break"
             };
}
-(void)setRunningTotal:(NSNumber *)runningTotal{
    _runningTotal = runningTotal;
    NSLog(@"Setting running total of %@ %@ to %@", self.habitIdentifier, self.day, runningTotal);
}
#pragma  mark - MTL Managed Object
+(NSString *)managedObjectEntityName{
    return @"HabitDay";
}
+(NSDictionary *)managedObjectKeysByPropertyKey{
    return @{};
}
+(NSSet *)propertyKeysForManagedObjectUniquing{
    return [NSSet setWithArray:@[@"habitIdentifier",@"day"]];
}
@end
