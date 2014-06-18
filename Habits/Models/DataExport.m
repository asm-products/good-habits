//
//  DataExport.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "DataExport.h"
#import "Habit.h"
#import <NSArray+F.h>
#import <Mantle.h>
#import "HabitsList.h"
@implementation DataExport


+(void)run:(UIViewController *)controller{
    NSArray * habits = [MTLJSONAdapter JSONArrayFromModels:[HabitsList all]];
    NSLog(@"Habits json: %@", habits);
//    NSString * hash = habits
}
@end
