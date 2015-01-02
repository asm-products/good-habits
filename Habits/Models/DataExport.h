//
//  DataExport.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataExport : NSObject
+(void)run:(UIViewController*)controller;
+(BOOL)importDataFromBase64EncodedString:(NSString*)string;
+(void)scanForJSONFile:(void(^)(BOOL success))callback;
@end
