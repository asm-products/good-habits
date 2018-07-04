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
#import <NSArray+F.h>
#import "Chain.h"
#import "Habit.h" 
#define STORE_NAME @"HabitsStore"
#define DB_NAME @"HabitsStore.sqlite"

// see http://www.objc.io/issue-10/icloud-core-data.html
// see http://www.objc.io/issue-4/full-core-data-application.html

@interface CoreDataClient(Privates)
- (NSDictionary *)iCloudPersistentStoreOptions;
@end

@implementation CoreDataClient
+(instancetype)defaultClient{
    static CoreDataClient * client = nil;
    if (client == nil){
        client = [CoreDataClient new];
    }
    return client;
}
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
-(instancetype)initWithReadOnlyStoreUrl:(NSURL *)readOnlyStoreUrl{
    if(self = [super init]){
        [self buildWithReadOnlyStoreURL:readOnlyStoreUrl];
    }
    return self;
}
-(void)build{
    [self registerForiCloudNotifications];
    [self setupManagedObjectContext];
//    [self nukeStore];
}
-(void)buildTestStore{
    NSURL  * storeURL = [self storeURLWithName:@"testing.sqlite"];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    [self buildStoreWithURL:storeURL];
}

-(void)buildWithReadOnlyStoreURL:(NSURL*)storeURL{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    NSDictionary * options =@{
                              NSPersistentStoreRemoveUbiquitousMetadataOption: @YES,
                              };
    self.persistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
    
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
}
-(void)buildStoreWithURL:(NSURL*)storeURL{
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
    return @{
//             NSPersistentStoreUbiquitousContentNameKey:STORE_NAME,
//             NSPersistentStoreRebuildFromUbiquitousContentOption: @YES,
             NSMigratePersistentStoresAutomaticallyOption: @YES,
             NSInferMappingModelAutomaticallyOption: @YES
            }; // @"MyHabitsStore". @"HabitsStore"
}
-(NSURL*)storeURLWithName:(NSString*)name{
//    NSURL *documentsDirectory = [[[NSFileManager defaultManager]
//                                  URLsForDirectory:NSDocumentDirectory
//                                  inDomains:NSUserDomainMask] lastObject];
    NSURL *documentsDirectory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.goodtohear.habits"];
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:name];
    return storeURL;
}
+(NSURL*)groupStoreURL{
    NSURL *documentsDirectory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.goodtohear.habits"];
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:DB_NAME];
    return storeURL;
}
-(NSURL*)storeURL{
    return [self storeURLWithName:DB_NAME];
}
-(NSManagedObjectModel*)managedObjectModel{
    NSURL *modelURL = [[NSBundle bundleForClass:self.class] URLForResource:@"Habits" withExtension:@"momd"];
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if(!model) @throw [NSException exceptionWithName:@"ManagedObjectModelNotFound" reason:@"Couldn't load managed object model" userInfo:nil];
    return model;
}
- (void)setupManagedObjectContext
{
    NSLog(@"Setting up default managed object context");
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    self.persistentStore = [self.persistentStoreCoordinator
                            addPersistentStoreWithType:NSSQLiteStoreType
                            configuration:nil
                            URL:self.storeURL
                            options:self.iCloudPersistentStoreOptions
                            error:&error];
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    NSURL * final_iCloudURL = self.persistentStore.URL;
//    self.storeURL = final_iCloudURL;

    if (error) {
        NSLog(@"Managed object context setup error: %@", error);
    }else{
        NSLog(@"Connected to store url %@ (tried to connect to %@)", final_iCloudURL, self.storeURL);
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
// If the application is running, Core Data will post this before responding to iCloud account changes or "Delete All" from Documents & Data.
/*
 SPersistentStoreCoordinatorStoresWillChangeNotification; object = <NSPersistentStoreCoordinator: 0x7f9a2b869270>; userInfo = {
 NSPersistentStoreUbiquitousTransitionTypeKey = 2;
 added =     (
 "<NSSQLCore: 0x7f9a2b81d290> (URL: 
 file:///Users/mf/Library/Developer/CoreSimulator/Devices/C9F4458D-F53F-4D67-AAA5-B1C0517FEED3/data/Containers/Data/Application/99262965-3130-4F66-A450-48E44AAF84CB/Documents/CoreDataUbiquitySupport/nobody~simB3C771C1-BF8F-5702-975F-E5F2669D8BC2/HabitsStore/local/store/HabitsStore.sqlite)"
 );
 removed =     (
 "<NSSQLCore: 0x7f9a2b81d290> (URL: 
 file:///Users/mf/Library/Developer/CoreSimulator/Devices/C9F4458D-F53F-4D67-AAA5-B1C0517FEED3/data/Containers/Data/Application/99262965-3130-4F66-A450-48E44AAF84CB/Documents/CoreDataUbiquitySupport/nobody~simB3C771C1-BF8F-5702-975F-E5F2669D8BC2/HabitsStore/local/store/HabitsStore.sqlite)"
 );
 }}
 */
- (void)storesWillChange:(NSNotification *)notification {
    NSLog(@"CORE DATA: Stores will change, %@", notification);
    NSManagedObjectContext *context = self.managedObjectContext;
	
    [context performBlockAndWait:^{
        NSError *error;
		
        if ([context hasChanges]) {
            BOOL success = [context save:&error];
            
            if (!success && error) {
                // perform error handling
                NSLog(@"Stores will change error: %@",[error localizedDescription]);
            }
        }
        
        [context reset];
    }];
    
    // Refresh User Interface.
    [HabitsQueries refresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:self];
}

- (void)storesDidChange:(NSNotification *)notification {
    // Refresh User Interface.
    dispatch_async(dispatch_get_main_queue(), ^{
        [HabitsQueries refresh];
        [[NSNotificationCenter defaultCenter] postNotificationName:HABITS_UPDATED object:self];
        
    });
    
}
-(void)migrateToAppGroupStore:(void (^)())completion{
    CoreDataClient * groupStoreClient = [CoreDataClient defaultClient];
    NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Habit"];
    request.predicate = [NSPredicate predicateWithValue:YES];
    NSArray * habits = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (Habit * habit in habits){
        NSMutableDictionary * habitDict = [habit committedValuesForKeys:nil].mutableCopy;
        [habitDict removeObjectsForKeys:@[@"chains",@"failures"]];
        Habit * newHabit = [NSEntityDescription insertNewObjectForEntityForName:@"Habit" inManagedObjectContext:groupStoreClient.managedObjectContext];
        [newHabit setValuesForKeysWithDictionary:habitDict];
        // habit
        // ^ failures ^ chains
        //               ^ days
        for(Failure *failure in habit.failures){
            Failure * newFailure = [NSEntityDescription insertNewObjectForEntityForName:@"Failure" inManagedObjectContext:groupStoreClient.managedObjectContext];
            NSMutableDictionary * failureDict = [failure committedValuesForKeys:nil].mutableCopy;
            [failureDict removeObjectsForKeys:@[@"habit"]];
            [newFailure setValuesForKeysWithDictionary:failureDict];
            [newHabit addFailuresObject:newFailure];
        }
        for(Chain * chain in habit.chains){
            Chain * newChain = [NSEntityDescription insertNewObjectForEntityForName:@"Chain" inManagedObjectContext:groupStoreClient.managedObjectContext];
            NSMutableDictionary * chainDict = [chain committedValuesForKeys:nil].mutableCopy;
            [chainDict removeObjectsForKeys:@[@"days",@"habit"]];
            [newChain setValuesForKeysWithDictionary:chainDict];
            [newHabit addChainsObject:newChain];
            for(HabitDay * day in chain.days){
                HabitDay * newDay = [NSEntityDescription insertNewObjectForEntityForName:@"HabitDay" inManagedObjectContext:groupStoreClient.managedObjectContext];
                NSMutableDictionary * dayDict = [day committedValuesForKeys:nil].mutableCopy;
                [dayDict removeObjectForKey:@"chain"];
                [newDay setValuesForKeysWithDictionary:dayDict];
                [newChain addDaysObject:newDay];
            }
        }
    }
    [groupStoreClient.managedObjectContext save:nil];
    completion();
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

-(NSArray*)allHabits{
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Habit"];
    NSError * error;
    return [self.managedObjectContext executeFetchRequest:request error:&error];
}
-(NSDate *)lastUsedDate{
    return [[self allHabits] reduce:^id(NSDate * date, Habit * habit) {
        Chain * chain = habit.currentChain;
        if (chain.lastDateCache != nil){
            return [chain.lastDateCache laterDate: date];
        }else{
            return date;
        }
    } withInitialMemo:[NSDate dateWithTimeIntervalSince1970:0]];
}
@end
