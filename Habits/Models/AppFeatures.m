//
//  AppFeature.m
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "AppFeatures.h"

@implementation AppFeatures
+(BOOL)statsEnabled{
    return [[NSUserDefaults standardUserDefaults] boolForKey:STATS_PURCHASED];
}
+(BOOL)shouldShowReasonInput{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"prompt_for_in_app_purchases"] != NO;
}
@end
