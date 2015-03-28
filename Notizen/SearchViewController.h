//
//  SearchViewController.h
//  Notizen
//
//  Created by Johannes Körner on 28.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SearchViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results

@end
