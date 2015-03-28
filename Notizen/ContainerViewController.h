//
//  ContainerViewController.h
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "BVReorderTableView.h"

@class NoteContainer, ModalTextView, ModalImageView, ModalMapView, NoteContent, Note, ContentChoiceView;

@interface ContainerViewController : UITableViewController </*ReorderTableViewDelegate, */NSFetchedResultsControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate> {
    UITextView *editingTextView;
    ModalTextView *textView;
    ModalImageView *imageView;
    ModalMapView *mapView;
    NoteContent *editingObject;
    
    UIImagePickerController *myCameraPicker;
    UIImagePickerController *myAlbumPicker;
    
    Note *editNote;
    
    UIToolbar *editToolbar;
    
    NSIndexPath *tempIndexPath;
    NSIndexPath *moveIndexPath;
    
    BOOL sequence;
    
    ContentChoiceView *contentChoice;
    
    CLLocationManager *locationManager;
    CLLocationCoordinate2D tempCoordinate;
    
    NSArray *activityItems;
    
    BOOL isDeleting;
}

@property (nonatomic, strong) NoteContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int pending;

@end
