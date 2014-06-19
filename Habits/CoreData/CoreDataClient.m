//
//  CoreDataClient.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CoreDataClient.h"
#import "HabitsList.h"
#import <UIAlertView+Blocks.h>

#define STORE_NAME @"HabitsStore"
#define DB_NAME @"HabitsStore.sqlite"


@interface CoreDataClient(Privates)
- (NSDictionary *)iCloudPersistentStoreOptions;
@end

@implementation CoreDataClient
-(instancetype)init{
    if(self = [super init]){
        [self build];
    }
    return self;
}
-(void)build{
    [self registerForiCloudNotifications];
    [self setupManagedObjectContext];
//    [self nukeStore];
}
-(void)nukeStore{
    NSError * error;
    NSURL * url = self.persistentStore.URL;
    NSLog(@"Delete store at url %@", url.absoluteString);
    BOOL success = [NSPersistentStoreCoordinator removeUbiquitousContentAndPersistentStoreAtURL:url options:@{NSPersistentStoreUbiquitousContentNameKey:STORE_NAME} error:&error];
    if(error || !success){
        NSLog(@"error! %@", error.localizedDescription);
    }
    if(success) NSLog(@"NUKED!");
    exit(0);
}
-(void)saveInBackground{
    [self.managedObjectContext performBlock:^{
        if([self.managedObjectContext hasChanges]){
            NSError * error;
            [self.managedObjectContext save:&error];
            if(error) NSLog(@"Error saving! %@", error.localizedDescription);
        }
    }];
}
/// Use these options in your call to -addPersistentStore:
- (NSDictionary *)iCloudPersistentStoreOptions {
    return @{NSPersistentStoreUbiquitousContentNameKey:STORE_NAME, NSMigratePersistentStoresAutomaticallyOption: @YES,
             NSInferMappingModelAutomaticallyOption: @YES}; // @"MyHabitsStore". @"HabitsStore"
}
-(NSURL*)storeURL{
    NSURL *documentsDirectory = [[[NSFileManager defaultManager]
                                  URLsForDirectory:NSDocumentDirectory
                                  inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:DB_NAME];
    return storeURL;
}
-(NSManagedObjectModel*)managedObjectModel{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Habits" withExtension:@"momd"];
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return model;
}
- (void)setupManagedObjectContext
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    self.persistentStore = [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:self.iCloudPersistentStoreOptions error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
}
#pragma mark - Notification Observers
- (void)registerForiCloudNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
    [notificationCenter addObserver:self
                           selector:@selector(storesWillChange:)
                               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                             object:self.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(storesDidChange:)
                               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                             object:self.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                             object:self.persistentStoreCoordinator];
}

# pragma mark - iCloud Support
- (void) persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)changeNotification {
    NSManagedObjectContext *context = self.managedObjectContext;
	
    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:changeNotification];
    }];
}

- (void)storesWillChange:(NSNotification *)notification {
    NSManagedObjectContext *context = self.managedObjectContext;
	
    [context performBlockAndWait:^{
        NSError *error;
		
        if ([context hasChanges]) {
            BOOL success = [context save:&error];
            
            if (!success && error) {
                // perform error handling
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        
        [context reset];
    }];
    
    // Refresh your User Interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:self];
}

- (void)storesDidChange:(NSNotification *)notification {
    // Refresh your User Interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:self];
    
}
@end
