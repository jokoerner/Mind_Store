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

@class NoteContainer, ModalTextView, ModalImageView, ModalMapView, NoteContent, Note, ContentChoiceView;

@interface ContainerViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    UITextView *editingTextView;
    ModalTextView *textView;
    ModalImageView *imageView;
    ModalMapView *mapView;
    NoteContent *editingObject;
    
    Note *editNote;
    
    ContentChoiceView *contentChoice;
    
    CLLocationManager *locationManager;
    CLLocationCoordinate2D tempCoordinate;
}

@property (nonatomic, strong) NoteContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
