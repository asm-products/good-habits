//
//  CoreDataClient.h
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;
@interface CoreDataClient : NSObject
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, strong) NSPersistentStore * persistentStore;
-(void)saveInBackground;
@end
