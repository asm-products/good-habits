//
//  Habit.m
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "Habit.h"
#import <NSArray+F.h>
#import "Colors.h"
@implementation Habit{
    NSInteger longestChain;
}
-(NSDictionary*)serialize{
    return @{
             @"title": _title,
             @"color_index": @(_colorIndex),
             @"created_at": _createdAt,
             @"days_checked": _daysChecked,
             @"time_to_do": @(_hourToDo),
             @"minute_to_do": @(_minuteToDo),
             @"active": @(_active),
             @"order": @(_order),
             @"days_required": _daysRequired,
             @"longest_chain": @(longestChain)
             };
}
+(NSInteger)nextOrder{
    return [[self all] count];
}
-(id)initWithOptions:(NSDictionary*)options{
    if(self = [super init]){
        if(!options) options = @{@"title": @"New Habit", @"active": @YES, @"days_checked": @[]};
        self.title = options[@"title"];
        self.active = options[@"active"] ? [options[@"active"] boolValue] : NO;
        self.colorIndex = options[@"color_index"] ? [options[@"color_index"] integerValue] : [Habit nextUnusedColorIndex];
        
    }
    return self;
}
+(NSInteger)nextUnusedColorIndex{
    if([self all] == nil) return 0;
    NSArray * occurrences = [[[self all] map:^id(Habit* obj) {
        return @(obj.colorIndex);
    }] arrayByAddingObjectsFromArray:[[Colors taskColors] mapWithIndex]];
    
    return 0;
}
@end
