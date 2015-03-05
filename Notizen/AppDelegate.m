//
//  AppDelegate.m
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "AppDelegate.h"
#import "ContainerViewController.h"
#import "MasterViewController.h"
#import "StoreHandler.h"
#import "NoteContainer.h"
#import "Note.h"
#import "NoteContent.h"

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //StoreHandler initialisieren
    [StoreHandler shared];
    
    [self initializeUserDefaults];
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSPersistentStoreCoordinatorStoresWillChangeNotification
     object:self.managedObjectContext.persistentStoreCoordinator
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *note) {
         post(@"disableUserInteraction");
         [self.managedObjectContext performBlock:^{
             if ([self.managedObjectContext hasChanges]) {
                 NSError *saveError;
                 if (![self.managedObjectContext save:&saveError]) {
                     NSLog(@"Save error: %@", saveError);
                 }
                 // check for account transition
                 if ([[note userInfo] valueForKey:NSPersistentStoreUbiquitousTransitionTypeKey] != nil) {
                     // transition -> no loop possible
                     post(@"dropReferencesToManagedObjects");
                     [self.managedObjectContext reset];
                 }
             } else {
                 post(@"dropReferencesToManagedObjects");
                 [self.managedObjectContext reset];
             }
         }];
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self deduplicate]; // remove all duplicates in the new persistent store
        post(@"enableUserInteraction");
        post(@"updateUserInterface");
    }];
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification
     object:self.managedObjectContext.persistentStoreCoordinator
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *note) {
         [self.managedObjectContext performBlock:^{
             [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
         }];
     }];
    
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;

    UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
    [self createSampleData];
    
    return YES;
}

- (void)initializeUserDefaults  {
    if (getDefault(@"ascending") == nil) {
        setDefault(@YES, @"ascending");
    }
}


- (void)createSampleData {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContainer" inManagedObjectContext:context];
    NoteContainer *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setTitle:@"Notizen"];
    
    entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newNote setNoteContainer:newManagedObject];
    
    entity = [NSEntityDescription entityForName:@"NoteContent" inManagedObjectContext:context];
    NoteContent *newContent = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newContent setIndex:@0];
    [newContent setDataType:@"text"];
    [newContent setData:[@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." dataUsingEncoding:NSUTF8StringEncoding]];
    [newContent setNote:newNote];
    
    [context save:nil];
}

- (void)deduplicate {
    NSArray *entitiesToCheck = @[@"NoteContainer", @"Note", @"NoteContent"];
    for (NSString *entity in entitiesToCheck) {
        [self deduplicateEntity:entity];
    }
}

- (void)deduplicateEntity:(NSString *)ent {
    NSString *uniquePropertyKey = @"myHash";
    NSExpression *countExpression = [NSExpression expressionWithFormat:@"count:(%@)", uniquePropertyKey];
    NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
    [countExpressionDescription setName:@"count"];
    [countExpressionDescription setExpression:countExpression];
    [countExpressionDescription setExpressionResultType:NSInteger64AttributeType];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:ent inManagedObjectContext:context];
    NSAttributeDescription *uniqueAttribute = [[entity attributesByName] objectForKey:uniquePropertyKey];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ent];
    [fetchRequest setPropertiesToFetch:@[uniqueAttribute, countExpression]];
    [fetchRequest setPropertiesToGroupBy:@[uniqueAttribute]];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSArray *fetchedDictionaries = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    NSMutableArray *valuesWithDupes = [NSMutableArray array];
    for (NSDictionary *dict in fetchedDictionaries) {
        NSNumber *count = dict[@"count"];
        if ([count integerValue] > 1) {
            [valuesWithDupes addObject:dict[@"myHash"]];
        }
    }
    
    NSFetchRequest *dupeFetchRequest = [NSFetchRequest fetchRequestWithEntityName:ent];
    [dupeFetchRequest setIncludesPendingChanges:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myHash IN (%@)", valuesWithDupes];
    [dupeFetchRequest setPredicate:predicate];
    NSArray *dupes = [self.managedObjectContext executeFetchRequest:dupeFetchRequest error:nil];
    
    Note *prevObject;
    for (Note *duplicate in dupes) {
        if (prevObject) {
            if ([duplicate.myHash isEqualToString:prevObject.myHash]) {
                if ([duplicate.timeStamp compare:prevObject.timeStamp] == NSOrderedAscending) {
                    [context deleteObject:duplicate];
                } else {
                    [context deleteObject:prevObject];
                    prevObject = duplicate;
                }
            } else {
                prevObject = duplicate;
            }
        } else {
            prevObject = duplicate;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[ContainerViewController class]] && ([(ContainerViewController *)[(UINavigationController *)secondaryViewController topViewController] container] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.johanneskorner.Notizen" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Notizen" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Notizen.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *storeOptions = @{NSPersistentStoreUbiquitousContentNameKey: @"MyAppCloudStore",
                                   NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSInferMappingModelAutomaticallyOption: @YES};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
