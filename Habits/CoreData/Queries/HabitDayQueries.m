//
//  HabitDayQueries.m
//  Habits
//
//  Created by Michael Forrest on 22/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "HabitDayQueries.h"
#import "HabitDay.h"
#import "HabitsQueries.h"
#import "CoreDataClient.h"
@implementation HabitDayQueries
+(NSArray *)daysForHabit:(Habit *)habit betweenDate:(NSDate *)startDate andDate:(NSDate*)endDate;
{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"HabitDay"];
    request.predicate = [NSPredicate predicateWithFormat:@"date >= %@ && date <= %@ && chain.habit == %@", startDate, endDate, habit];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    NSError * error;
    NSArray * result = [[CoreDataClient defaultClient].managedObjectContext executeFetchRequest:request error:&error];
    if(error) NSLog(@"Error fetching habit days %@", error.localizedDescription);
    return result;
}
@end
