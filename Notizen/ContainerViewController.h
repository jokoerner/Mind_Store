//
//  ContainerViewController.h
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class NoteContainer;

@interface ContainerViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NoteContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
