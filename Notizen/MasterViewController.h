//
//  MasterViewController.h
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "StoreHandler.h"

@class ContainerViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    UIImageView *topImageview;
    UIImageView *midImageview;
    UIImageView *botImageview;
}

@property (strong, nonatomic) ContainerViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

