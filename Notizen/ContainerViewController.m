//
//  ContainerViewController.m
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ContainerViewController.h"
#import "NoteContent.h"
#import "NoteContainer.h"
#import "TextCell.h"
#import "ImageCell.h"
#import "LocationCell.h"
#import "AudioCell.h"
#import "StoreHandler.h"
#import "ModalTextView.h"
#import "ModalImageView.h"
#import "ModalMapView.h"
#import "ContentChoiceView.h"
#import "Note.h"
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "MoveViewController.h"
#import "RotationController.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)handleAppearance {
    setBackgroundForView(self.navigationController.view);
    UIImageView *background = [self.navigationController.view.subviews objectAtIndex:0];
    [background setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height-64)];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    UIView *clearView = [[UIView alloc] initWithFrame:CGRectNull];
    [clearView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:clearView];
    
    self.navigationController.navigationBar.tintColor = customTintColor;
}

- (void)handleCellAppearance:(UITableViewCell *)cell {
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = customTableFont;
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
//    if (section == 0) {
//        label.frame = CGRectMake(20, 28, 320, 20);
//    }
//    else {
        label.frame = CGRectMake(20, 8, 320, 20);
//    }
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont systemFontOfSize:14];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self handleAppearance];
}

- (void)resetBarButtonItems {
    [self.navigationItem setHidesBackButton:NO animated:YES];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    if (self.managedObjectContext && self.container) {
        self.navigationItem.rightBarButtonItems = @[addButton, self.editButtonItem];
    }
    else {
        self.navigationItem.rightBarButtonItems = @[];
    }
    
    if (iPhone) {
        self.navigationItem.leftBarButtonItems = @[];
    }
    else if (self.navigationItem.leftBarButtonItems.count >= 1 && self.splitViewController.displayModeButtonItem) {
        self.navigationItem.leftBarButtonItems = @[self.splitViewController.displayModeButtonItem];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self resetBarButtonItems];
    
    observe(self, @selector(handleAccessoryButtonAction:), @"accessoryButtonAction");
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    post(@"hidingImageView");
    removeObserverForName(self, @"accessoryButtonAction");
    
    if (iPad && textView) removeObserver(textView);
    if (iPad && contentChoice) [contentChoice cancel];
    
    [[StoreHandler shared] stopAudio];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.fetchedResultsController.fetchedObjects.count == 0 && self.managedObjectContext && self.container) {
        [self insertNewObject:nil];
    }
    else if (self.searchIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.searchIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        self.searchIndexPath = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Neues Objekt erstellen

- (NoteContent *)neuerNoteContentInNote:(Note *)note {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContent" inManagedObjectContext:context];
    NoteContent *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    if (note) {
        if (tempIndexPath) {
            //Indices danach erhöhen
            NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
            NSArray *allObjects = [note.noteContents.allObjects sortedArrayUsingDescriptors:@[sd]];
            for (int i = (int)tempIndexPath.row+1; i < allObjects.count; i++) {
                NoteContent *aContent = [allObjects objectAtIndex:i];
                [aContent setIndex:@(i+1)];
            }
            
            [newManagedObject setIndex:@(tempIndexPath.row+1)];
            
            tempIndexPath = nil;
            editNote = nil;
        }
        else {
            [newManagedObject setIndex:@(note.noteContents.count)];
        }
        [newManagedObject setNote:note];
    }
    else {
        entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
        Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newNote setNoteContainer:self.container];
        [newManagedObject setNote:newNote];
        [newManagedObject setIndex:@0];
    }
    
    return newManagedObject;
}

- (NoteContent *)neuerNoteContentInNote:(Note *)note atIndex:(NSInteger)index {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContent" inManagedObjectContext:context];
    NoteContent *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setIndex:@(index)];
    [newManagedObject setNote:note];
    
    return newManagedObject;
}

- (void)insertNewObject:(UIBarButtonItem *)item {
    if (!contentChoice) {
        CGFloat width;
        CGFloat heigth;
        if (iPhone) {
            width = self.navigationController.view.superview.frame.size.width;
            heigth = self.navigationController.view.superview.frame.size.height;
        }
        else if (iPad) {
            width = self.navigationController.view.frame.size.width;
            heigth = self.navigationController.view.frame.size.height;
        }
        
        contentChoice = [[ContentChoiceView alloc] initWithFrame:CGRectMake(width/4.0, (heigth/2.0-width/4.0), width/2.0, width/2.0)];
        
        if (iPhone) {
            [contentChoice showInView:self.navigationController.view.superview.superview.superview];
        }
        else {
            [contentChoice showInView:self.navigationController.view];
        }
        
        observe(self, @selector(compose:), @"ContentChoiceViewCompose");
        observe(self, @selector(photo:), @"ContentChoiceViewPhoto");
        observe(self, @selector(audio:), @"ContentChoiceViewAudio");
        observe(self, @selector(location:), @"ContentChoiceViewLocation");
        observe(self, @selector(contentChoiceCleanup), @"ContentChoiceViewDidDismiss");
    }
}

- (void)compose:(NSNotification *)notification {
    textView = [[ModalTextView alloc] initWithText:@""];
    [textView setOffset:64.0];
    CGRect frame = [self.view convertRect:contentChoice.frame fromView:self.navigationController.view.superview.superview.superview];
    [textView showFromFrame:frame onTopOfView:self.navigationController.view];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNextNewItem:)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTextView:)];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTextView:)];
    [self.navigationItem setRightBarButtonItems:@[item, addItem] animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItems:@[trash] animated:YES];
    [self.tableView setScrollEnabled:NO];
}

- (void)photo:(NSNotification *)notification {
    [self takePhoto:nil];
}

- (void)audio:(NSNotification *)notification {
    NSData *audioData = notification.object;
    
    NoteContent *newContent = [self neuerNoteContentInNote:editNote];
    [newContent setDataType:@"audio"];
    [newContent setData:audioData];
    
    [self.managedObjectContext save:nil];
}

- (void)location:(NSNotification *)notification {
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager requestAlwaysAuthorization];
    }
    CLLocationCoordinate2D coordinate = locationManager.location.coordinate;
    NSData *data = [NSData dataWithBytes:&coordinate length:sizeof(coordinate)];
    
    NoteContent *newContent = [self neuerNoteContentInNote:editNote];
    [newContent setDataType:@"location"];
    [newContent setData:data];
    
    [self.managedObjectContext save:nil];
}

- (void)dismissContentChoice {
    [contentChoice cancel];
    [self contentChoiceCleanup];
}

- (void)contentChoiceCleanup {
    removeObserverForName(self, @"ContentChoiceViewCompose");
    removeObserverForName(self, @"ContentChoiceViewPhoto");
    removeObserverForName(self, @"ContentChoiceViewAudio");
    removeObserverForName(self, @"ContentChoiceViewLocation");
    removeObserverForName(self, @"ContentChoiceViewDidDismiss");
    contentChoice = nil;
}

- (void)insertNextNewItem:(UIBarButtonItem *)item {
    sequence = YES;
    
    if (textView) {
        [self dismissTextView:nil];
    }
    else if (imageView) {
        [self dismissImageView:nil];
    }
    else if (mapView) {
        [self dismissMapView:nil];
    }
    
    [self insertNewObject:nil];
}

- (void)insertItemAfterIndexPath:(NSIndexPath *)indexPath {
    //Content-Objekt einfügen
    tempIndexPath = indexPath;
    NoteContent *theContent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    editNote = theContent.note;
    [self insertNewObject:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    NSString *oldString = [sectionInfo name];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    NSDate *date = [dateFormatter dateFromString:oldString];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    NSString *newString = [dateFormatter stringFromDate:date];
    
    return newString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteContent *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *dataType = object.dataType;
    
    if (moveIndexPath == indexPath) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReorderCell" forIndexPath:indexPath];
        //cell.backgroundColor = [UIColor colorWithRed:0.4 green:1.0 blue:0.4 alpha:0.15];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    if ([dataType isEqualToString:@"text"]) {
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        NSString *text = [[NSString alloc] initWithData:object.data encoding:NSUTF8StringEncoding];
        cell.noteTextView.text = text;
        CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        [cell.noteTextView setFrame:CGRectMake(5, 0, self.view.frame.size.width-10, height)];
        
        //[cell setmuchEditing:self.editing];
        [self handleCellAppearance:cell];
        return cell;
    }
    else if ([dataType isEqualToString:@"image"]) {
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        UIImage *image = [UIImage imageWithData:object.data];
        cell.noteImageView.image = image;
        
        //[cell setMuchEditing:self.editing];
        [self handleCellAppearance:cell];
        return cell;
    }
    else if ([dataType isEqualToString:@"video"]) {
        //TODO
    }
    else if ([dataType isEqualToString:@"audio"]) {
        AudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioCell" forIndexPath:indexPath];
        [cell initWithAudioData:object.data];
        
        //[cell setMuchEditing:self.editing];
        [self handleCellAppearance:cell];
        return cell;
    }
    else if ([dataType isEqualToString:@"location"]) {
        LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
        NSData *data = object.data;
        CLLocationCoordinate2D coordinate;
        [data getBytes:&coordinate length:sizeof(coordinate)];
        [cell addAnnotationForCoordinate:coordinate];
        
        //[cell setMuchEditing:self.editing];
        [self handleCellAppearance:cell];
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = NSLocalizedString(@"Error - Please delete this", nil);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteContent *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *dataType = object.dataType;
    if ([dataType isEqualToString:@"text"]) {
        NSString* text = [[NSString alloc] initWithData:object.data encoding:NSUTF8StringEncoding];
        
        NSDictionary *attributes = @{NSFontAttributeName: customMediumTableFont};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        CGFloat height = rect.size.height+14;
        
        attributes = @{NSFontAttributeName: customTableFont};
        rect = [text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        CGFloat height2 = rect.size.height;
        
        if (height2 <= 44.0) {
            return 44.0;
        }
        
        return MAX(height+10, 46.0);
    }
    else if ([dataType isEqualToString:@"image"]) {
        UIImage *image = [UIImage imageWithData:object.data];
        if (image.size.height < 300) {
            return image.size.height;
        }
        return 300.0;
    }
    else if ([dataType isEqualToString:@"video"]) {
        //TODO
    }
    else if ([dataType isEqualToString:@"audio"]) {
        return 60.0;
    }
    else if ([dataType isEqualToString:@"location"]) {
        return 240.0;
    }
    return 44.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NoteContent *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([self tableView:tableView numberOfRowsInSection:indexPath.section] == 1) {
            //Letzter Content -> Note löschen
            [context deleteObject:object.note];
        }
        else {
            isDeleting = YES;
            [context deleteObject:object];
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }];
    
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Share", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //Share
        NoteContent *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIActivityViewController *activity;
        
        if ([object.dataType isEqualToString:@"text"]) {
            NSString *content = [[NSString alloc] initWithData:object.data encoding:NSUTF8StringEncoding];
            activity = [[UIActivityViewController alloc] initWithActivityItems:@[content] applicationActivities:nil];
        }
        else if ([object.dataType isEqualToString:@"image"]) {
            UIImage *content = [UIImage imageWithData:object.data];
            activity = [[UIActivityViewController alloc] initWithActivityItems:@[content] applicationActivities:nil];
        }
        else if ([object.dataType isEqualToString:@"location"]) {
            CLLocationCoordinate2D coordinate;
            [object.data getBytes:&coordinate length:sizeof(coordinate)];
            
            CLGeocoder *coder = [[CLGeocoder alloc] init];
            CLLocation *theLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:object.timeStamp];
            
            [coder reverseGeocodeLocation:theLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSString *addressName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
                NSString *content = addressName;
                UIActivityViewController *activity2 = [[UIActivityViewController alloc] initWithActivityItems:@[content] applicationActivities:nil];
                activity2.popoverPresentationController.sourceView = self.navigationController.view;
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                activity2.popoverPresentationController.sourceRect = [self.tableView convertRect:cell.frame toView:self.navigationController.view];
                activity2.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                [self.navigationController presentViewController:activity2 animated:YES completion:nil];
            }];
            return;
        }
        else if ([object.dataType isEqualToString:@"audio"]) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setTimeStyle:NSDateFormatterNoStyle];
            [df setDateStyle:NSDateFormatterShortStyle];
            NSString *theString = [[[df stringFromDate:object.timeStamp] stringByReplacingOccurrencesOfString:@"/" withString:@":"] stringByAppendingString:@".caf"];
            
            NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:theString];
            [object.data writeToFile:file atomically:YES];
            NSURL *url = [NSURL fileURLWithPath:file];
            activity = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        }
        
        activity.popoverPresentationController.sourceView = self.navigationController.view;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        activity.popoverPresentationController.sourceRect = [self.tableView convertRect:cell.frame toView:self.navigationController.view];
        activity.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self.navigationController presentViewController:activity animated:YES completion:^{
            [self setEditing:NO animated:YES];
        }];
    }];
    [action2 setBackgroundColor:[UIColor grayColor]];
    
    UITableViewRowAction *action3 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Insert", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self insertItemAfterIndexPath:indexPath];
        [self setEditing:NO animated:YES];
    }];
    [action3 setBackgroundColor:[UIColor orangeColor]];
    
    return @[action1, action2, action3];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        [self showEditToolbar];
        return;
    }
    
    NoteContent *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    editingObject = object;
    if ([object.dataType isEqualToString:@"text"]) {
        if (!actionDictionary) {
            NSString *testString = [[NSString alloc] initWithData:object.data encoding:NSUTF8StringEncoding];
            NSDataDetector *detectAddress = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeAddress error:nil];
            NSArray *addressMatches = [detectAddress matchesInString:testString options:0 range:NSMakeRange(0, [testString length])];
            NSDataDetector *detectLink = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
            NSArray *linkMatches = [detectLink matchesInString:testString options:0 range:NSMakeRange(0, [testString length])];
            NSDataDetector *detectPhone = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypePhoneNumber error:nil];
            NSArray *phoneMatches = [detectPhone matchesInString:testString options:0 range:NSMakeRange(0, [testString length])];
            //TODO alles in ActionView zeigen
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (NSTextCheckingResult *address in addressMatches) {
                NSString *key = [NSString stringWithFormat:@"addr %d", (int)dic.allKeys.count];
                NSString *addressString = [NSString stringWithFormat:@"%@+%@+%@+%@+%@+%@",
                                           [address.addressComponents valueForKey:NSTextCheckingNameKey],
                                           [address.addressComponents valueForKey:NSTextCheckingStreetKey],
                                           [address.addressComponents valueForKey:NSTextCheckingZIPKey],
                                           [address.addressComponents valueForKey:NSTextCheckingCityKey],
                                           [address.addressComponents valueForKey:NSTextCheckingStateKey],
                                           [address.addressComponents valueForKey:NSTextCheckingCountryKey]];
                [dic setValue:addressString forKey:key];
            }
            for (NSTextCheckingResult *link in linkMatches) {
                NSString *key = [NSString stringWithFormat:@"link %d", (int)dic.allKeys.count];
                [dic setValue:link.URL.absoluteString forKey:key];
            }
            for (NSTextCheckingResult *phone in phoneMatches) {
                NSString *key = [NSString stringWithFormat:@"call %d", (int)dic.allKeys.count];
                [dic setValue:phone.phoneNumber forKey:key];
            }
            if (dic.allKeys.count == 0) {
                actionDictionary = nil;
                
                TextCell *cell = (TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
                textView = [[ModalTextView alloc] initWithText:cell.noteTextView.text];
                [textView setOffset:64.0];
                CGRect frame = [self.view convertRect:cell.noteTextView.frame fromView:cell];
                [textView showFromFrame:frame onTopOfView:self.navigationController.view];
                UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNextNewItem:)];
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTextView:)];
                UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTextView:)];
                [self.navigationItem setRightBarButtonItems:@[item, addItem] animated:YES];
                [self.navigationItem setHidesBackButton:YES animated:YES];
                [self.navigationItem setLeftBarButtonItems:@[trash] animated:YES];
                [self.tableView setScrollEnabled:NO];
                
                return;
            }
            [dic setValue:@(indexPath.row) forKey:@"row"];
            [dic setValue:@(indexPath.section) forKey:@"section"];
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Edit", nil) otherButtonTitles:nil, nil];
            [sheet setTag:3];
            
            NSMutableArray *optionen = [[dic.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
            for (NSInteger i = optionen.count-1; i >= 0; i--) {
                if ([[optionen objectAtIndex:i] isEqualToString:@"row"] || [[optionen objectAtIndex:i] isEqualToString:@"section"]) {
                    [optionen removeObjectAtIndex:i];
                }
            }
            
            for (NSString *key in optionen) {
                NSString *buttonTitle = [dic valueForKey:key];
                [sheet addButtonWithTitle:buttonTitle];
            }
            
            actionDictionary = dic;
            [sheet showFromRect:[self.tableView cellForRowAtIndexPath:indexPath].frame inView:self.view animated:YES];
        }
        else {
            actionDictionary = nil;
            
            TextCell *cell = (TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            textView = [[ModalTextView alloc] initWithText:cell.noteTextView.text];
            [textView setOffset:64.0];
            CGRect frame = [self.view convertRect:cell.noteTextView.frame fromView:cell];
            [textView showFromFrame:frame onTopOfView:self.navigationController.view];
            UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNextNewItem:)];
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTextView:)];
            UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTextView:)];
            [self.navigationItem setRightBarButtonItems:@[item, addItem] animated:YES];
            [self.navigationItem setHidesBackButton:YES animated:YES];
            [self.navigationItem setLeftBarButtonItems:@[trash] animated:YES];
            [self.tableView setScrollEnabled:NO];
        }
    }
    else if ([object.dataType isEqualToString:@"image"]) {
        post(@"showingImageView");
        ImageCell *cell = (ImageCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        [self.tableView setUserInteractionEnabled:NO];
        imageView = [[ModalImageView alloc] initWithImage:cell.noteImageView.image];
        [imageView setOffset:64.0];
        
        CGRect frame = [self.view convertRect:cell.noteImageView.frame fromView:cell];
        if (iPhone) {
            [imageView showFromFrame:frame onTopOfView:self.navigationController.view];
        }
        else {
            [imageView showFromFrame:[self.view convertRect:frame toView:self.splitViewController.view] onTopOfView:self.splitViewController.view];
        }
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissImageView:)];
        UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteImageView:)];
        UIBarButtonItem *newImage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto:)];
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNextNewItem:)];
        [self.navigationItem setRightBarButtonItems:@[item, addItem] animated:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];
        [self.navigationItem setLeftBarButtonItems:@[trash, newImage] animated:YES];
        [self.tableView setScrollEnabled:NO];
    }
    else if ([object.dataType isEqualToString:@"location"]) {
        NSData *data = object.data;
        CLLocationCoordinate2D coordinate;
        [data getBytes:&coordinate length:sizeof(coordinate)];
        
        LocationCell *cell = (LocationCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        [self.tableView setUserInteractionEnabled:NO];
        mapView = [[ModalMapView alloc] initWithCoordinate:coordinate];
        [mapView setOffset:64.0];
        CGRect frame = [self.view convertRect:cell.noteMapView.frame fromView:cell];
        [mapView showFromFrame:frame onTopOfView:self.navigationController.view];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissMapView:)];
        UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteMapView)];
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNextNewItem:)];
        observe(self, @selector(openLocationInMaps), @"openLocationInMaps");
        [self.navigationItem setRightBarButtonItems:@[item, addItem] animated:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];
        [self.navigationItem setLeftBarButtonItems:@[trash] animated:YES];
        [self.tableView setScrollEnabled:NO];
        
        
        tempCoordinate = coordinate;
    }
}

//#pragma mark - PinchGesture
//
//-(void)handlePinchGesture:(UIPinchGestureRecognizer*)gestureRecognizer {
//    if(UIGestureRecognizerStateEnded == [gestureRecognizer state]){
//        NSLog(@"begin");
//        NSLog(@"%.2f", gestureRecognizer.scale);
//    }
//}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!self.managedObjectContext || !self.container) {
        post(@"noContainer");
        return nil;
    }
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContent" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"note IN %@", self.container.notes];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"note.creation.description" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor, sortDescriptor2];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"note.creation.description" cacheName:self.container.myHash];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            if (!isDeleting) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            if (!isDeleting) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //Do something
        isDeleting = NO;
    });
//    [self.tableView performSelector:@selector(beginUpdates) withObject:nil afterDelay:0.4];
//    [self.tableView performSelector:@selector(endUpdates) withObject:nil afterDelay:0.5];
//    [self.tableView reloadSectionIndexTitles];
}

#pragma mark - ModalTextView

- (void)deleteTextView:(NSNotification *)notification {
    if (editingObject) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        editingObject = nil;
    }
    
    editNote = nil;
    sequence = NO;
    
    [textView dismiss];
    textView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
}

- (void)dismissTextView:(UIBarButtonItem *)item {
    if (textView.textView.text.length < 1) {
        editingObject = nil;
        sequence = NO;
    }
    else if ([[textView.textView.text substringFromIndex:textView.textView.text.length-1] isEqualToString:@" "]) {
        textView.textView.text = [textView.textView.text substringToIndex:textView.textView.text.length-1];
    }
    
    if (textView.textView.text.length < 1) {
        editingObject = nil;
        sequence = NO;
    }
    else {
        if (editingObject) {
            NoteContent *object = editingObject;
            [object setData:[textView.textView.text dataUsingEncoding:NSUTF8StringEncoding]];
            [self.managedObjectContext save:nil];
            editNote = editingObject.note;
            editingObject = nil;
        }
        else {
            //Neue Text-Notiz erstellen
            NoteContent *newContent = [self neuerNoteContentInNote:editNote];
            [newContent setDataType:@"text"];
            editNote = newContent.note;
            
            NSData* data = [textView.textView.text dataUsingEncoding:NSUTF8StringEncoding];
            [newContent setData:data];
            
            [self.managedObjectContext save:nil];
        }
    }
    
    if (item) {
        editNote = nil;
        sequence = NO;
    }
    
    [textView dismiss];
    textView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - ModalImageView

//- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated {
//    if (!myImagePicker) return;
//    
//    if (myImagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
//        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
//        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
//    } else {
////        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
////        viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:button];
////        viewController.navigationItem.title = @"Take Photo";
////        viewController.navigationController.navigationBarHidden = NO; // important
////        viewController.navigationController.navigationBar.layer.opacity = 0.4;
//        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20, 2, 40, 40)];
//        [button setImage:[UIImage imageNamed:@"Picture"] forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(showLibrary:) forControlEvents:UIControlEventTouchUpInside];
//        myImagePicker.cameraOverlayView = button;
//    }
//}

- (void)showCamera:(id)sender {
    [myAlbumPicker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showLibrary:(id)sender {
    if (!myAlbumPicker) {
        myAlbumPicker = [[UIImagePickerController alloc] init];
        myAlbumPicker.delegate = self;
        myAlbumPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        myAlbumPicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        myAlbumPicker.modalPresentationStyle = UIModalPresentationPageSheet;
        //Wird nur aufgerufen nachdem die Kamera schon gezeigt wurde
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
        myAlbumPicker.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
    }
    if (myCameraPicker) {
        [myCameraPicker presentViewController:myAlbumPicker animated:YES completion:NULL];
    }
}

- (void)takePhoto:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        myCameraPicker = [[UIImagePickerController alloc] init];
        myCameraPicker.delegate = self;
        myCameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20, 2, 40, 40)];
        [button setImage:[UIImage imageNamed:@"Picture"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showLibrary:) forControlEvents:UIControlEventTouchUpInside];
        myCameraPicker.cameraOverlayView = button;
        
        [myCameraPicker setModalPresentationStyle:UIModalPresentationPageSheet];
        [self.navigationController presentViewController:myCameraPicker animated:YES completion:NULL];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        myAlbumPicker = [[UIImagePickerController alloc] init];
        myAlbumPicker.delegate = self;
        myAlbumPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [myAlbumPicker setModalPresentationStyle:UIModalPresentationPageSheet];
        [self.navigationController presentViewController:myAlbumPicker animated:YES completion:NULL];
    }
    else {
        // TODO alert, no camera available
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"No camera available", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedChosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *finalImage = chosenImage;
    if (editedChosenImage) finalImage = editedChosenImage;
    if (imageView) {
        [imageView updateImage:finalImage];
    }
    else {
        // Neuen Inhalt erstellen
        NoteContent *newContent = [self neuerNoteContentInNote:editNote];
        [newContent setDataType:@"image"];
        
        NSData* data = UIImageJPEGRepresentation(finalImage, 0.9);
        [newContent setData:data]; //TODO? : evtl. in async Block
        
        [self.managedObjectContext save:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    myCameraPicker = nil;
    myAlbumPicker = nil;
}

- (void)deleteImageView:(NSNotification *)notification {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [imageView dismiss];
    imageView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    editingObject = nil;
    editNote = nil;
    sequence = NO;
}

- (void)dismissImageView:(UIBarButtonItem *)item {
    post(@"hidingImageView");
    NoteContent *object = editingObject;
    editNote = object.note;
    [self.tableView setUserInteractionEnabled:YES];
    
    if (imageView.didTakePhoto) {
        ImageCell *cell = (ImageCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        cell.imageView.image = imageView.imageView.image;
        
        NSData* data = UIImageJPEGRepresentation(imageView.imageView.image, 0.9);
        [object setData:data]; //TODO? : evtl. in async Block
        
        [self.managedObjectContext save:nil];
    }
    
    if (item) {
        editNote = nil;
        sequence = NO;
    }
    
    [imageView dismiss];
    imageView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    if (selectedRow) [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    editingObject = nil;
}

#pragma mark - ModalMapView

- (void)dismissMapView:(UIBarButtonItem *)item {
    NoteContent *object = editingObject;
    editNote = object.note;
    [self.tableView setUserInteractionEnabled:YES];
    
    NSData* data = [NSData dataWithBytes:&tempCoordinate length:sizeof(tempCoordinate)];
    [object setData:data];
    [self.managedObjectContext save:nil];
    
    if (item) {
        editNote = nil;
        sequence = NO;
    }
    
    [mapView dismiss];
    mapView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    editingObject = nil;
}

- (void)deleteMapView {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [mapView dismiss];
    mapView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    editingObject = nil;
    editNote = nil;
    sequence = NO;
}

- (void)openLocationInMaps {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Do you want to leave the app?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Open in Apple Maps", nil) otherButtonTitles:nil, nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) { //Location zeigen
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:tempCoordinate addressDictionary:nil]];
            [item openInMapsWithLaunchOptions:nil];
        }
    }
    else if (actionSheet.tag == 2) { //Ausgewählte löschen
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [self deleteSelectedItemsImpl];
        }
    }
    else if (actionSheet.tag == 3) { //Kontext-Aktion für TextViews
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            actionDictionary = nil;
            return;
        }
        
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:
                                                        [[actionDictionary valueForKey:@"row"] integerValue]
                                                        inSection:
                                      [[actionDictionary valueForKey:@"section"] integerValue]];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            return;
        }
        
        NSMutableArray *optionen = [[actionDictionary.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
        for (NSInteger i = optionen.count-1; i >= 0; i--) {
            if ([[optionen objectAtIndex:i] isEqualToString:@"row"] || [[optionen objectAtIndex:i] isEqualToString:@"section"]) {
                [optionen removeObjectAtIndex:i];
            }
        }
        
        NSString *key = [optionen objectAtIndex:buttonIndex-2];
        if ([[key substringToIndex:4] isEqualToString:@"addr"]) {
            NSString *addressOnMap = [actionDictionary valueForKey:key];
            NSString* addr = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@",addressOnMap];
            NSURL* url = [[NSURL alloc] initWithString:[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if ([[key substringToIndex:4] isEqualToString:@"link"]) {
            NSURL* url = [[NSURL alloc] initWithString:[actionDictionary valueForKey:key]];
            [[UIApplication sharedApplication] openURL:url];
        }
        else if ([[key substringToIndex:4] isEqualToString:@"call"]) {
            NSString *urlString = [NSString stringWithFormat:@"tel:%@", [actionDictionary valueForKey:key]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

#pragma mark - Edit Toolbar

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        
    }
    else {
        [self dismissEditToolbar];
    }
}

- (UIToolbar *)editToolbar {
    UIToolbar *theToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height, 300, 44)];
    
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelectedItems:)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareSelectedItems:)];
    UIBarButtonItem *move = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(moveSelectedItems:)];
    //UIBarButtonItem *merge = [[UIBarButtonItem alloc] initWithTitle:@"▶︎⊕◀︎" style:UIBarButtonItemStylePlain target:self action:@selector(mergeSelectedItems:)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [theToolbar setItems:@[move/*, flex, merge*/, flex, share, flex, delete]];
    
    [theToolbar.layer setMasksToBounds:YES];
    [theToolbar.layer setCornerRadius:5.0];
    
    return theToolbar;
}

- (void)showEditToolbar {
    if (editToolbar) {
        return;
    }
    editToolbar = [self editToolbar];
    [self.navigationController.view addSubview:editToolbar];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = editToolbar.frame;
        frame.origin.y -= 50;
        [editToolbar setFrame:frame];
    }];
}

- (void)dismissEditToolbar {
    if (!editToolbar) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = editToolbar.frame;
        frame.origin.y += 50;
        [editToolbar setFrame:frame];
    } completion:^(BOOL finished) {
        [editToolbar removeFromSuperview];
        editToolbar = nil;
    }];
}

- (void)deleteSelectedItems:(UIBarButtonItem *)item {
    NSString *destructive = [NSString stringWithFormat:@"%@ (%ld)", NSLocalizedString(@"Delete", nil), (long)(self.tableView.indexPathsForSelectedRows.count)];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:destructive otherButtonTitles:nil, nil];
    [sheet setTag:2];
    [sheet showFromBarButtonItem:item animated:YES];
}

- (void)deleteSelectedItemsImpl {
    isDeleting = YES;
    
    NSArray *selected = self.tableView.indexPathsForSelectedRows;
    
    NSMutableArray *collectedObjects = [NSMutableArray array];
    NSMutableArray *collectedObjects2 = [NSMutableArray array];
    NSMutableArray *notesToKeep = [NSMutableArray array];
    
    //Content-Objekte und Note-Objekte sammeln
    for (NSIndexPath *indexPath in selected) {
        NoteContent *aContentObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [collectedObjects addObject:aContentObject];
        if (![notesToKeep containsObject:aContentObject.note]) [notesToKeep addObject:aContentObject.note];
    }
    
    //Content-Objekte löschen, Note-Objekte sammeln
    for (NSInteger i = collectedObjects.count-1; i >= 0; i--) {
        NoteContent *aContentObject = [collectedObjects objectAtIndex:i];
        Note *aNote = (aContentObject.note.noteContents.count > 1) ? nil : aContentObject.note;
        
        [self.managedObjectContext deleteObject:aContentObject];
        if (aNote) [collectedObjects2 addObject:aNote];
    }
    
    //Note-Objekte löschen
    for (NSInteger i = collectedObjects2.count-1; i >= 0; i--) {
        Note *aNote = [collectedObjects2 objectAtIndex:i];
        [self.managedObjectContext deleteObject:aNote];
    }
    
    [self.managedObjectContext save:nil];
}

- (void)shareSelectedItems:(UIBarButtonItem *)item {
    NSArray *selected = self.tableView.indexPathsForSelectedRows;
    
    NSMutableArray *collectedObjects = [NSMutableArray array];
    
    //Content-Objekte sammeln
    for (NSIndexPath *indexPath in selected) {
        NoteContent *aContentObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [collectedObjects addObject:aContentObject];
    }
    
    NSMutableArray *idObjects = [NSMutableArray array];
    
    for (NoteContent *object in collectedObjects) {
        if ([object.dataType isEqualToString:@"text"]) {
            NSString *content = [[[NSString alloc] initWithData:object.data encoding:NSUTF8StringEncoding] stringByAppendingString:@"\n"];
            [idObjects addObject:content];
        }
        else if ([object.dataType isEqualToString:@"image"]) {
            UIImage *content = [UIImage imageWithData:object.data];
            [idObjects addObject:content];
        }
        else if ([object.dataType isEqualToString:@"location"]) {
            CLLocationCoordinate2D coordinate;
            [object.data getBytes:&coordinate length:sizeof(coordinate)];
            
            CLGeocoder *coder = [[CLGeocoder alloc] init];
            CLLocation *theLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:object.timeStamp];
            
            self.pending++;
            [coder reverseGeocodeLocation:theLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSString *addressName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
                NSString *content = [addressName stringByAppendingString:@"\n"];
                [idObjects addObject:content];
                self.pending--;
            }];
        }
        else if ([object.dataType isEqualToString:@"audio"]) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setTimeStyle:NSDateFormatterNoStyle];
            [df setDateStyle:NSDateFormatterShortStyle];
            NSString *theString = [[[df stringFromDate:object.timeStamp] stringByReplacingOccurrencesOfString:@"/" withString:@":"] stringByAppendingString:@".caf"];
            
            NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:theString];
            [object.data writeToFile:file atomically:YES];
            NSURL *url = [NSURL fileURLWithPath:file];
            [idObjects addObject:url];
        }
    }
    
    if (self.pending > 0) {
        [self addObserver:self forKeyPath:@"pending" options:0 context:nil];
        activityItems = idObjects;
    }
    else {
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:idObjects applicationActivities:nil];
        if (iPad) {
            activity.popoverPresentationController.sourceView = self.navigationController.view;
            activity.popoverPresentationController.sourceRect = [editToolbar convertRect:[(UIView *)[editToolbar.subviews objectAtIndex:1] frame] toView:self.navigationController.view];
        }
        [self.navigationController presentViewController:activity animated:YES completion:nil];
    }
}

- (void)moveSelectedItems:(UIBarButtonItem *)item {
    NSMutableArray *noteContents = [NSMutableArray array];
    NSArray *noteContentIndexPaths = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in noteContentIndexPaths) {
        NoteContent *noteContent = (NoteContent *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [noteContents addObject:noteContent];
    }
    
    MoveViewController *vc = [[MoveViewController alloc] initWithStyle:UITableViewStylePlain];
    [vc setNoteContents:noteContents];
    [vc setManagedObjectContext:self.managedObjectContext];
    RotationController *rotation = [[RotationController alloc] initWithRootViewController:vc];
    if (iPad) {
        [rotation setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    [self.navigationController presentViewController:rotation animated:YES completion:nil];
}

- (void)mergeSelectedItems:(UIBarButtonItem *)item {
    NSMutableArray *notes = [NSMutableArray array];
    NSArray *noteContentIndexPaths = [self.tableView indexPathsForSelectedRows];
    
    //Note-Objekte finden
    for (NSIndexPath *indexPath in noteContentIndexPaths) {
        Note *note = [(NoteContent *)[self.fetchedResultsController objectAtIndexPath:indexPath] note];
        if (![notes containsObject:note]) {
            [notes addObject:note];
        }
    }
    
    //Nichts zu mergen
    if (notes.count < 2) return;
    
    //Nach Erstellungsdatum sortieren
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"creation" ascending:YES];
    notes = [[notes sortedArrayUsingDescriptors:@[sd]] mutableCopy];
    
    //Mergen
    for (NSUInteger i = notes.count-1; i > 0; i--) {
        Note *note = [notes objectAtIndex:i];
        Note *bigPoppa = [notes objectAtIndex:i-1];
        NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        NSArray *noteContents = [note.noteContents.allObjects sortedArrayUsingDescriptors:@[sd2]];
        NSUInteger bigPoppaCount = bigPoppa.noteContents.count;
        for (NoteContent *content in noteContents) {
            content.index = @(content.index.integerValue + bigPoppaCount); //neue Objekte nach alten Objekten
            [note removeNoteContentsObject:content];
            [content setNote:bigPoppa];
        }
        [notes removeObject:note];
        [self.managedObjectContext deleteObject:note];
    }
    
    for (NSIndexPath *ip in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:ip animated:YES];
    }
    [self.managedObjectContext save:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"pending"]) {
        if (self.pending == 0) {
            UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            if (iPad) {
                activity.popoverPresentationController.sourceView = self.navigationController.view;
                activity.popoverPresentationController.sourceRect = [editToolbar convertRect:[(UIView *)[editToolbar.subviews objectAtIndex:1] frame] toView:self.navigationController.view];
            }
            [self.navigationController presentViewController:activity animated:YES completion:nil];
            activityItems = nil;
            [self removeObserver:self forKeyPath:@"pending"];
        }
    }
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if (iPad) {
             [self moveToNewOrientation];
             if (mapView) [mapView updateSize:self.navigationController.view.frame.size];
             if (textView) [textView updateSize:self.navigationController.view.frame.size];
             if (imageView) [imageView updateSize:self.splitViewController.view.frame.size];
             if (contentChoice) [contentChoice updateSize:self.navigationController.view.frame.size];
             return;
         }
         
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
             // transitioning to landscape
             if (imageView) {
                 [imageView moveToLandscapeWithSize:size];
                 if (iPhone) {
                     [self.navigationController setNavigationBarHidden:YES animated:YES];
                     [self moveToNewOrientation];
                 }
             }
         }
         else {
             // transitioning to portrait
             if (imageView) {
                 [imageView moveToPortraitWithSize:size];
                 if (iPhone) {
                     [self.navigationController setNavigationBarHidden:NO animated:YES];
                     [self moveToNewOrientation];
                 }
             }
         }
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)moveToNewOrientation {
    UIImageView *background = [self.navigationController.view.subviews objectAtIndex:0];
    [background setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height-64)];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    
}

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    if (iPad) {
        return UIInterfaceOrientationMaskAll;
    }
    if (imageView) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    if (iPad) {
        return YES;
    }
    if (imageView) {
        return YES;
    }
    return NO;
}

#pragma mark - accessoryButtonAction

- (void)handleAccessoryButtonAction:(NSNotification *)notification {
    UITableViewCell *cell = notification.object;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self insertItemAfterIndexPath:indexPath];
}

#pragma mark - BVReorderTableView

// This method is called when the long press gesture is triggered starting the re-ording process.
// You insert a blank row object into your data source and return the object you want to save for
// later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    moveIndexPath = indexPath;
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    moveIndexPath = toIndexPath;
//    id object = [_objects objectAtIndex:fromIndexPath.row];
//    [_objects removeObjectAtIndex:fromIndexPath.row];
//    [_objects insertObject:object atIndex:toIndexPath.row];
}


// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    NoteContent *movedContent = (NoteContent *)object;
    NoteContent *currentContent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Note *newNote = currentContent.note;
    Note *oldNote = movedContent.note;
    
    //Objekt aus dem alten Note-Objekt entfernen
    [oldNote removeNoteContentsObject:movedContent];
    
    //Indices updaten
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray *oldContents = [oldNote.noteContents.allObjects sortedArrayUsingDescriptors:@[sd]];
    for (NSInteger i = 0; i < oldContents.count; i++) {
        NoteContent *someContent = [oldContents objectAtIndex:i];
        [someContent setIndex:@(i)];
    }
    
    //Indices der Objekte danach erhöhen
    NSArray *newContents = [newNote.noteContents.allObjects sortedArrayUsingDescriptors:@[sd]];
    for (NSInteger i = indexPath.row; i < newContents.count; i++) {
        NoteContent *someContent = [newContents objectAtIndex:i];
        [someContent setIndex:@(i+1)];
    }
    
    //Index setzen
    movedContent.index = @(indexPath.row);
    
    //Zu neuem Note-Objekt hinzufügen
    [movedContent setNote:newNote];
    
    // do any additional cleanup here
    moveIndexPath = nil;
}

#pragma mark - Andere

- (void)updateIndicesForNote:(Note *)note {
    NSArray *array = [[note.noteContents allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    for (int i = 0; i < array.count; i++) {
        NoteContent *content = [array objectAtIndex:i];
        [content setIndex:@(i)];
    }
}


@end