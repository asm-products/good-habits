//
//  LegacyJSONConverter.h
//  Habits
//
//  Created by Michael Forrest on 15/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LegacyJSONImporter : NSObject

+(void)performMigrationWithArray:(NSArray*)array;
@end
