//
//  ChainBreak.m
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ChainBreak.h"
#import "HabitsList.h"
@implementation ChainBreak
-(void)confirmAndSave{
    NSError * error;
    [MTLManagedObjectAdapter managedObjectFromModel:self insertingIntoContext:[HabitsList coreDataClient].managedObjectContext error:&error];
}
+ (NSString *)managedObjectEntityName{
    return @"ChainBreak";
}

+ (NSDictionary *)managedObjectKeysByPropertyKey;{
    return @{};
}

+ (NSSet *)propertyKeysForManagedObjectUniquing{
    return [NSSet setWithObjects:@"habitIdentifier", @"date", nil];
}
@end
