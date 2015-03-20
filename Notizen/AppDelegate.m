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
#import "RotationController.h"
#import <MapKit/MapKit.h>

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    
    replyDictionary = [NSMutableDictionary dictionary];
    
    if ([[userInfo valueForKey:@"addToLast"] boolValue]) {
        addToLast = YES;
    }
    else {
        addToLast = NO;
    }
    
    if ([[userInfo valueForKey:@"action"] isEqualToString:@"saveNote"]) {
        //Notiz speichern
        theInfo = [userInfo valueForKey:@"info"];
        
        if (theInfo.length == 0) {
            [replyDictionary setValue:@"No Input" forKey:@"error"];
            reply(replyDictionary);
            return;
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContainer" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.title LIKE %@", @" Watch"];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        NoteContainer *watchContainer;
        if (results.count == 0) {
            //erstellen
            watchContainer = [self newNoteContainer];
            [watchContainer setTitle:@" Watch"];
        }
        else {
            watchContainer = [results lastObject];
        }
        
        Note *newNote = [self newNote];
        [newNote setNoteContainer:watchContainer];
        NoteContent *newContent = [self newNoteContent];
        [newContent setNote:newNote];
        [newContent setIndex:@(newNote.noteContents.count-1)];
        [newContent setDataType:@"text"];
        [newContent setData:[theInfo dataUsingEncoding:NSUTF8StringEncoding]];
        
        theInfo = nil;
        [self.managedObjectContext save:nil];
        
        [replyDictionary setValue:@"NO" forKey:@"error"];
        reply(replyDictionary);
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [replyDictionary setValue:@"LocationServicesError" forKey:@"error"];
        reply(replyDictionary);
        return;
    }
    
    backgroundID = [application beginBackgroundTaskWithName:@"getLocation" expirationHandler:^{
        
    }];
    
    once = NO;
    theReply = reply;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.pausesLocationUpdatesAutomatically = YES;
    [locationManager startUpdatingLocation];
    
    if ([[userInfo valueForKey:@"action"] isEqualToString:@"saveLocation"]) {
        //Ort speichern
        theInfo = [userInfo valueForKey:@"info"];
        showLocations = NO;
    }
    else if ([[userInfo valueForKey:@"action"] isEqualToString:@"showLocations"]) {
        //Orte und aktuellen Standort senden
        showLocations = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    if (once) {
        return;
    }
    once = YES;
    
    CLLocation *currentLocation = newLocation;
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    NSData *data = [NSData dataWithBytes:&currentCoordinate length:sizeof(currentCoordinate)];
    
    //NSLog(@"Current Location: %.0f %.0f", currentCoordinate.latitude, currentCoordinate.longitude);
    
    if (showLocations) { //aktuelle Position und Orte im Umkreis von 500 Metern geben
        [replyDictionary setValue:data forKey:@"currentLocation"];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContent" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataType LIKE %@", @"location"];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        
        NSMutableArray *filtered = [NSMutableArray array];
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        for (int i = 1; i <= results.count; i++) {
            NoteContent *content = [results objectAtIndex:i-1];
            NSData *data = content.data;
            CLLocationCoordinate2D coordinate;
            [data getBytes:&coordinate length:sizeof(coordinate)];
            CLLocation *aLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:content.timeStamp];
            if ([aLocation distanceFromLocation:currentLocation] <= 500) {
                //im Umkreis
                [filtered addObject:data];
            }
        }
        
        [replyDictionary setValue:filtered forKey:@"locations"];
    }
    else { //aktuelle Position speichern
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContainer" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.title LIKE %@", @" Watch"];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setEntity:entity];
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        NoteContainer *watchContainer;
        if (results.count == 0) {
            //erstellen
            watchContainer = [self newNoteContainer];
            [watchContainer setTitle:@" Watch"];
        }
        else {
            watchContainer = [results lastObject];
        }
        Note *newNote = [self newNote];
        [newNote setNoteContainer:watchContainer];
        NoteContent *newContent = [self newNoteContent];
        [newContent setNote:newNote];
        [newContent setIndex:@(newNote.noteContents.count-1)];
        [newContent setDataType:@"location"];
        [newContent setData:data];
        
        if (theInfo.length > 0) {
            [newContent setIndex:@(newContent.index.integerValue+1)]; //Location nach Text zeigen
            newContent = [self newNoteContent];
            [newContent setNote:newNote];
            [newContent setIndex:@(newNote.noteContents.count-1)];
            [newContent setDataType:@"text"];
            [newContent setData:[theInfo dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [[self managedObjectContext] save:nil];
    }
    theInfo = nil;
    [replyDictionary setValue:@"NO" forKey:@"error"];
    theReply(replyDictionary);
    [[UIApplication sharedApplication] endBackgroundTask:backgroundID];
}

- (NoteContainer *)newNoteContainer {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContainer" inManagedObjectContext:context];
    NoteContainer *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    return newManagedObject;
}

- (Note *)newNote {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"noteContainer.title LIKE %@", @" Watch"];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (Note *note in results) {
        if ([[NSDate date] timeIntervalSinceDate:note.creation] < 4) {
            //alte Note zurückgeben
            return note;
        }
    }
    
    if (addToLast && results.count > 0) {
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"creation" ascending:YES];
        results = [results sortedArrayUsingDescriptors:@[sd]];
        return (Note *)[results lastObject];
    }
    
    entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    Note *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    return newManagedObject;
}

- (NoteContent *)newNoteContent {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContent" inManagedObjectContext:context];
    NoteContent *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    return newManagedObject;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    theReply(replyDictionary);
    [[UIApplication sharedApplication] endBackgroundTask:backgroundID];
}


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
    RotationController *navigationController = [splitViewController.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
    splitViewController.delegate = self;

    RotationController *masterNavigationController = splitViewController.viewControllers[0];
    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
    //[self createSampleData];
    
    return YES;
}

- (void)initializeUserDefaults  {
    if (getDefault(@"ascending") == nil) {
        setDefault(@YES, @"ascending");
    }
    if (getDefault(@"recordQualityVoice") == nil) {
        setDefault(@YES, @"recordQualityVoice");
    }
}


- (void)createSampleData {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContainer" inManagedObjectContext:context];
    NoteContainer *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setTitle:@"Notizen Text 2"];
    
    entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newNote setNoteContainer:newManagedObject];
    
    entity = [NSEntityDescription entityForName:@"NoteContent" inManagedObjectContext:context];
    NoteContent *newContent = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
//    CGDataProviderRef provider = CGImageGetDataProvider([[UIImage imageNamed:@"Background"] CGImage]);
//    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    [newContent setIndex:@0];
    [newContent setDataType:@"text"];
    [newContent setData:[@"Lorem ipsum dolor sit amet\n crazy stuff\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad\nso bad" dataUsingEncoding:NSUTF8StringEncoding]];
    //[newContent setData:UIImageJPEGRepresentation([UIImage imageNamed:@"Background"], 1.0)];
    //CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(40.446947, -102.047607);
    //NSData *data = [NSData dataWithBytes:&coordinate length:sizeof(coordinate)];
    //[newContent setData:data];
    
    //NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Audio.m4a" withExtension:nil]];
    //[newContent setData:data];
    
    [newContent setNote:newNote];
    
    [context save:nil];
}

- (void)deduplicate {
    // TODO 
//    NSArray *entitiesToCheck = @[@"NoteContainer", @"Note", @"NoteContent"];
//    for (NSString *entity in entitiesToCheck) {
//        [self deduplicateEntity:entity];
//    }
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
    if ([secondaryViewController isKindOfClass:[RotationController class]] && [[(RotationController *)secondaryViewController topViewController] isKindOfClass:[ContainerViewController class]] && ([(ContainerViewController *)[(RotationController *)secondaryViewController topViewController] container] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)splitViewControllerSupportedInterfaceOrientations:(UISplitViewController *)splitViewController {
    return UIInterfaceOrientationMaskPortrait;
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
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
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
