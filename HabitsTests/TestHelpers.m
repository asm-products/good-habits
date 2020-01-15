//
//  TestHelpers.m
//  Habits
//
//  Created by Michael Forrest on 09/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "TestHelpers.h"
#import "Calendar.h"
#import <NSArray+F.h>
#import "PlistStoreToCoreDataMigrator.h"
#import "HabitsQueries.h"
#import <OCMock.h>
#import "AppFeatures.h"
@implementation TestHelpers
+(Habit *)habit:(NSDictionary *)dict daysChecked:(NSArray *)dayKeys{
//    NSError * error;
//    Habit * result = [[Habit alloc] initWithDictionary:dict error:&error];
//    if(error) @throw [NSException exceptionWithName:@"Bad habit error" reason:error.localizedDescription userInfo:@{@"error":error}];
//    if(dayKeys)
//        [result checkDays:dayKeys];
//    return result;
    return  nil;
}
+(NSMutableArray *)everyDay{
    return [[Calendar days] map:^id(id obj) {
        return @YES;
    }].mutableCopy;
}
+(NSArray *)days:(NSArray *)dayStrings{
//    return [dayStrings map:^id(NSString * string) {
//        return [DayKeys dateFromKey:string];
//    }];
    return nil;
}
+(void)deleteAllData{
    [HabitsQueries deleteAllHabits];
    [HabitsQueries refresh];
}
+(void)loadFixtureFromUserDefaultsNamed:(NSString *)name{
    [HabitsQueries deleteAllHabits];
    [HabitsQueries refresh];
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist" inDirectory: [NSLocale currentLocale].languageCode];
    NSBundle * testBundle = [NSBundle bundleForClass:[self class]];
    if(!path) path = [testBundle pathForResource:name ofType:@"plist"];
    if(!path) @throw [NSException exceptionWithName:@"NoFixtureFound" reason:[NSString stringWithFormat:@"Couldn't find %@.plist anywhwere", name] userInfo:nil];
    NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray * array = [[dict valueForKeyPath:@"goodtohear.habits_habits"] map:^NSDictionary*(NSDictionary* record) {
        NSMutableDictionary * result = [record mutableCopy];
        result[@"title"] = NSLocalizedStringWithDefaultValue(record[@"title"], nil, testBundle, nil, nil);
        return result;
    }];
    [PlistStoreToCoreDataMigrator performMigrationWithArray:array progress:^(float progress) {
    }];
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];
    
}
+(void)setStatsEnabled:(BOOL)enabled{
    OCMockObject * mockClass = [OCMockObject mockForClass:[AppFeatures class]];
    [[[mockClass stub] andReturnValue:@(enabled)] statsEnabled];
    [[NSNotificationCenter defaultCenter] postNotificationName:PURCHASE_COMPLETED object:nil];
}

@end
