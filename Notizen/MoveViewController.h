//
//  MoveViewController.h
//  Notizen
//
//  Created by Johannes Körner on 20.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "StoreHandler.h"
#import "NoteContent.h"
#import "Note.h"
#import "NoteContainer.h"

@interface MoveViewController : UITableViewController<NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *noteContents;

@end
