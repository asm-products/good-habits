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
-(void)destroy{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"ChainBreak"];
    request.predicate = [NSPredicate predicateWithFormat:@"date == %@ AND habitIdentifier == %@", self.date, self.habitIdentifier];
    NSManagedObject * object = [[HabitsList coreDataClient].managedObjectContext executeFetchRequest:request error:nil].firstObject;
    [[HabitsList coreDataClient].managedObjectContext deleteObject:object];
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
