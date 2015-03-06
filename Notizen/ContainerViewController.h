//
//  ContainerViewController.h
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class NoteContainer, ModalTextView, NoteContent;

@interface ContainerViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextViewDelegate> {
    UITextView *editingTextView;
    ModalTextView *textView;
    NoteContent *editingObject;
}

@property (nonatomic, strong) NoteContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
