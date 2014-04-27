//
//  Habit.h
//  Habits
//
//  Created by Michael Forrest on 27/04/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Habit : NSObject
@property (nonatomic, strong) NSString * title;
@property (nonatomic) NSInteger colorIndex;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSArray * daysChecked;
@property (nonatomic) NSInteger hourToDo;
@property (nonatomic) NSInteger minuteToDo;
@property (nonatomic) BOOL active;
@property (nonatomic) NSInteger order;
@property (nonatomic, strong) NSArray * daysRequired;
@property (nonatomic, strong) NSArray * notifications;

-(id)initWithOptions:(NSDictionary*)options;
+(NSArray*)all;
+(NSArray*)activeToday;
+(NSArray*)carriedOver;
+(NSArray*)activeButNotToday;
+(NSArray*)inactive;
@end
