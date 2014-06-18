//
//  CoreDataClient.m
//  Habits
//
//  Created by Michael Forrest on 18/06/2014.
//  Copyright (c) 2014 Good To Hear. All rights reserved.
//

#import "CoreDataClient.h"
#import "HabitsList.h"

@import CoreData;

@implementation CoreDataClient{
    NSManagedObjectContext * _managedObjectContext;
    NSURL * iCloudStoreURL;
}
-(NSManagedObjectContext*)managedObjectContext{
    if(!_managedObjectContext)
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    return _managedObjectContext;
}
-(void)saveInBackground{
    [self.managedObjectContext performBlock:^{
        NSError * error;
        [self.managedObjectContext save:&error];
        if(error) NSLog(@"Error saving managed object context %@", error);
    }];
}
-(instancetype)init{
    if(self = [super init]){
        [self setup];
    }
    return self;
}

-(void)waitForOneTimeSetup{
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSPersistentStoreCoordinatorStoresWillChangeNotification
     object:self.managedObjectContext.persistentStoreCoordinator
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *note) {
         [self.managedObjectContext performBlock:^{
             if ([self.managedObjectContext hasChanges]) {
                 NSError *saveError;
                 if (![self.managedObjectContext save:&saveError]) {
                     NSLog(@"Save error: %@", saveError);
                 }
             } else {
                 [self.managedObjectContext reset];
             }
         }];
     }];

}
-(void)setup{
    NSURL *documentsDirectory = [[[NSFileManager defaultManager]
                                  URLsForDirectory:NSDocumentDirectory
                                  inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:@"Habits.sqlite"];
    NSError *error = nil;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Habits" withExtension:@"momd"];
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc]
                                                 initWithManagedObjectModel:model];
    self.managedObjectContext.persistentStoreCoordinator = coordinator;
    
    NSDictionary *storeOptions = @{NSPersistentStoreUbiquitousContentNameKey: @"HabitsCloudStore",
                                   NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSInferMappingModelAutomaticallyOption: @YES};
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:storeURL
                                                               options:storeOptions
                                                                 error:&error];
    iCloudStoreURL = [store URL];
    [self waitForOneTimeSetup];
    [self trackChangesFrom_iCloudAndOtherContexts];
}
-(void)trackChangesFrom_iCloudAndOtherContexts{
    void (^block)(NSNotification*) = ^(NSNotification *note) {
        [self.managedObjectContext performBlockAndWait:^{
            [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
        }];
        [HabitsList refreshFromManagedObjectContext:self.managedObjectContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:nil];

        
    };
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification
     object:self.managedObjectContext.persistentStoreCoordinator
     queue:[NSOperationQueue mainQueue]
     usingBlock:block];
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSManagedObjectContextDidSaveNotification
     object:self.managedObjectContext.persistentStoreCoordinator
     queue:[NSOperationQueue mainQueue]
     usingBlock:block];
;
}

@end
