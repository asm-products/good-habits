//
//  CoreDataClient.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CoreDataClient.h"
#import "HabitsQueries.h"
#import <UIAlertView+Blocks.h>

#define STORE_NAME @"HabitsStore"
#define DB_NAME @"HabitsStore.sqlite"

// see http://www.objc.io/issue-10/icloud-core-data.html
// see http://www.objc.io/issue-4/full-core-data-application.html

@interface CoreDataClient(Privates)
- (NSDictionary *)iCloudPersistentStoreOptions;
@end

@implementation CoreDataClient

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(CoreDataClient, defaultClient);

-(instancetype)init{
    if(self = [super init]){
        if(TEST_ENVIRONMENT){
            [self buildTestStore];
        }else{
            [self build];
        }
       
        [self listenForPrivateQueueSaves];
    }
    return self;
}
-(void)build{
    [self registerForiCloudNotifications];
    [self setupManagedObjectContext];
//    [self nukeStore];
}
-(void)buildTestStore{
    NSURL * storeURL = [self storeURLWithName:@"testing.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    self.persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
}
-(void)listenForPrivateQueueSaves{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
    }];
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
//-(void)saveInBackground{
//    [self.managedObjectContext performBlock:^{
//        if([self.managedObjectContext hasChanges]){
//            NSError * error;
//            [self.managedObjectContext save:&error];
//            if(error) NSLog(@"Error saving! %@", error.localizedDescription);
//        }
//    }];
//}
-(NSManagedObjectContext *)createPrivateContext{
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return context;
}
/// Use these options in your call to -addPersistentStore:
- (NSDictionary *)iCloudPersistentStoreOptions {
    return @{NSPersistentStoreUbiquitousContentNameKey:STORE_NAME, NSMigratePersistentStoresAutomaticallyOption: @YES,
             NSInferMappingModelAutomaticallyOption: @YES}; // @"MyHabitsStore". @"HabitsStore"
}
-(NSURL*)storeURLWithName:(NSString*)name{
    NSURL *documentsDirectory = [[[NSFileManager defaultManager]
                                  URLsForDirectory:NSDocumentDirectory
                                  inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:name];
    return storeURL;
}
-(NSURL*)storeURL{
    return [self storeURLWithName:DB_NAME];
}
-(NSManagedObjectModel*)managedObjectModel{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Habits" withExtension:@"momd"];
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if(!model) @throw [NSException exceptionWithName:@"ManagedObjectModelNotFound" reason:@"Couldn't load managed object model" userInfo:nil];
    return model;
}
- (void)setupManagedObjectContext
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    self.persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:self.iCloudPersistentStoreOptions error:&error];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;

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
    
    // Refresh User Interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:self];
}

- (void)storesDidChange:(NSNotification *)notification {
    // Refresh User Interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:self];
    
}
#pragma mark - Saving
-(void)save{
    NSError * error;
    if([self.managedObjectContext save:&error]){
        NSLog(@"Saved");
    }else{
        NSLog(@"Saving failed %@", error.localizedDescription);
    }
    
}
@end
