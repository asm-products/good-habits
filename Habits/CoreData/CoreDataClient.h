//
//  CoreDataClient.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataClient : NSObject
-(NSManagedObjectContext*)managedObjectContext;
-(void)saveInBackground;
@end
