//
//  MotionToMantleMigrator.h
//  Habits
//
//  Created by Michael Forrest on 17/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MotionToMantleMigrator : NSObject
+(BOOL)dataCanBeMigrated;
+(void)performMigration;
@end
