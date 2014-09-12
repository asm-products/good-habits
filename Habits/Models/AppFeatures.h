//
//  AppFeature.h
//  Habits
//
//  Created by Michael Forrest on 11/07/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NAGGING_DISABLED @"NAGGING_DISABLED"

@interface AppFeatures : NSObject
+(BOOL)statsEnabled;
+(BOOL)shouldShowReasonInput;
@end
