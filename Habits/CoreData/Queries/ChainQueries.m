//
//  ChainQueries.m
//  Habits
//
//  Created by Michael Forrest on 22/08/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "ChainQueries.h"
#import <YLMoment.h>
#import "CoreDataClient.h"
#import "Habit.h"
@import CoreData;

@implementation ChainQueries
+(NSArray *)chainsInMonthStarting:(NSDate *)date{
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Chain"];
    NSDate * endDate = [[[YLMoment momentWithDate:date] endOf:@"month"] date];
    request.predicate = [NSPredicate predicateWithFormat:@"days.date >= %@ && days.date <= %@", date, endDate];
    request.relationshipKeyPathsForPrefetching = @[@"days"];
    request.resultType = NSDictionaryResultType; // I'm hoping this will limit the subsequent operations to, at most, 30 records, so extracting the chains and stuff should be okay.
    
    NSError * error;
    NSArray * result = [[CoreDataClient defaultClient].managedObjectContext executeFetchRequest:request error:&error];
    if(error) NSLog(@"Error fetching chains %@", error.localizedDescription);
    return result;
}
+(NSArray *)chainLengthsDistributionForHabit:(Habit *)habit{
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Chain"];
    NSExpressionDescription * countExpressionDescription = [NSExpressionDescription new];
    countExpressionDescription.name = @"count";
    countExpressionDescription.expression = [NSExpression expressionForFunction:@"count:" arguments: @[[NSExpression expressionForKeyPath:@"daysCountCache"]]];
    fetchRequest.propertiesToFetch = @[@"daysCountCache", countExpressionDescription];
    fetchRequest.propertiesToGroupBy = @[@"daysCountCache"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"habit == %@", habit];
    
    fetchRequest.resultType = NSDictionaryResultType;
    NSError * error;
    NSArray * result = [[CoreDataClient defaultClient].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error){
        NSLog(@"error %@", error.localizedDescription);
    }else{
        NSLog(@"Result %@", result);
    }
    return [result sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"daysCountCache" ascending:NO]]];
}
@end
