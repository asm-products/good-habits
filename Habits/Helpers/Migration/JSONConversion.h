//
//  JSONImporter.h
//  Habits
//
//  Created by Michael Forrest on 15/09/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataClient.h"
@interface JSONConversion : NSObject
+(NSArray*)allHabitsAsJSONWithClient:(CoreDataClient*)coreDataClient;
+(void)performImportWithArray:(NSArray*)array;
@end
