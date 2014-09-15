//
//  JSONImporter.m
//  Habits
//
//  Created by Michael Forrest on 15/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "JSONConversion.h"
#import "Habit.h"
#import "HabitsQueries.h"
@implementation JSONConversion
+(NSArray *)allHabitsAsJSON{
    return [MTLJSONAdapter JSONArrayFromModels:[HabitsQueries all]];
}
@end
