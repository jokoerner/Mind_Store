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

@interface ContainerViewController ()

@end

@implementation ContainerViewController

- (void)handleAppearance {
    setBackgroundForView(self.navigationController.view);
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
    if (section == 0) {
        label.frame = CGRectMake(20, 28, 320, 20);
    }
    else {
        label.frame = CGRectMake(20, 8, 320, 20);
    }
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
    [self resetBarButtonItems];
    [self handleAppearance];
}

- (void)resetBarButtonItems {
    [self.navigationItem setHidesBackButton:NO animated:YES];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItems = @[addButton, self.editButtonItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[StoreHandler shared] stopAudio];
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
        [newManagedObject setIndex:@(note.noteContents.count)];
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

- (void)insertNewObject:(UIBarButtonItem *)item {
    if (!contentChoice) {
        CGFloat width = self.navigationController.view.superview.frame.size.width;
        CGFloat heigth = self.navigationController.view.superview.frame.size.height;
        contentChoice = [[ContentChoiceView alloc] initWithFrame:CGRectMake(width/4.0, (heigth/2.0-width/4.0), width/2.0, width/2.0)];
        [contentChoice showInView:self.navigationController.view.superview.superview.superview];
        
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
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTextView:)];
    UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTextView:)];
    [self.navigationItem setRightBarButtonItems:@[item] animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setLeftBarButtonItems:@[trash] animated:YES];
    [self.tableView setScrollEnabled:NO];
}

- (void)photo:(NSNotification *)notification {
    [self takePhoto:nil];
}

- (void)audio:(NSNotification *)notification {
    
}

- (void)location:(NSNotification *)notification {
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager requestWhenInUseAuthorization];
    }
    CLLocationCoordinate2D coordinate = locationManager.location.coordinate;
    NSData *data = [NSData dataWithBytes:&coordinate length:sizeof(coordinate)];
    
    NoteContent *newContent = [self neuerNoteContentInNote:editNote];
    [newContent setDataType:@"location"];
    [newContent setData:data];
    
    [self.managedObjectContext save:nil];
}

- (void)dismissContentChoice {
    [contentChoice dismiss];
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
    if ([dataType isEqualToString:@"text"]) {
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        NSString *text = [[NSString alloc] initWithData:object.data encoding:NSUTF8StringEncoding];
        cell.noteTextView.text = text;
        CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        [cell.noteTextView setFrame:CGRectMake(5, 0, self.view.frame.size.width-10, height)];
        
        [self handleCellAppearance:cell];
        return cell;
    }
    else if ([dataType isEqualToString:@"image"]) {
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        UIImage *image = [UIImage imageWithData:object.data];
        cell.noteImageView.image = image;
        CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        [cell.noteImageView setFrame:CGRectMake(5, 0, self.view.frame.size.width-10, height)];
        
        [self handleCellAppearance:cell];
        return cell;
    }
    else if ([dataType isEqualToString:@"video"]) {
        //TODO
    }
    else if ([dataType isEqualToString:@"audio"]) {
        AudioCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioCell" forIndexPath:indexPath];
        [cell initWithAudioData:object.data];
        
        [self handleCellAppearance:cell];
        return cell;
    }
    else if ([dataType isEqualToString:@"location"]) {
        LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
        CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        [cell.noteMapView setFrame:CGRectMake(5, 0, self.view.frame.size.width-10, height)];
        NSData *data = object.data;
        CLLocationCoordinate2D coordinate;
        [data getBytes:&coordinate length:sizeof(coordinate)];
        [cell addAnnotationForCoordinate:coordinate];
        
        [self handleCellAppearance:cell];
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"Fehler - bitte löschen";
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

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }];
    
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Share", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        // TODO: Share
    }];
    
    return @[action1, action2];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteContent *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    editingObject = object;
    if ([object.dataType isEqualToString:@"text"]) {
        TextCell *cell = (TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        textView = [[ModalTextView alloc] initWithText:cell.noteTextView.text];
        [textView setOffset:64.0];
        CGRect frame = [self.view convertRect:cell.noteTextView.frame fromView:cell];
        [textView showFromFrame:frame onTopOfView:self.navigationController.view];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTextView:)];
        UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTextView:)];
        [self.navigationItem setRightBarButtonItems:@[item] animated:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];
        [self.navigationItem setLeftBarButtonItems:@[trash] animated:YES];
        [self.tableView setScrollEnabled:NO];
    }
    else if ([object.dataType isEqualToString:@"image"]) {
        ImageCell *cell = (ImageCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        [self.tableView setUserInteractionEnabled:NO];
        imageView = [[ModalImageView alloc] initWithImage:cell.noteImageView.image];
        [imageView setOffset:64.0];
        CGRect frame = [self.view convertRect:cell.noteImageView.frame fromView:cell];
        [imageView showFromFrame:frame onTopOfView:self.navigationController.view];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissImageView:)];
        UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteImageView:)];
        UIBarButtonItem *newImage = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto:)];
        [self.navigationItem setRightBarButtonItems:@[item] animated:YES];
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
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissMapView)];
        UIBarButtonItem *trash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteMapView)];
        observe(self, @selector(openLocationInMaps), @"openLocationInMaps");
        [self.navigationItem setRightBarButtonItems:@[item] animated:YES];
        [self.navigationItem setHidesBackButton:YES animated:YES];
        [self.navigationItem setLeftBarButtonItems:@[trash] animated:YES];
        [self.tableView setScrollEnabled:NO];
        
        
        tempCoordinate = coordinate;
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
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
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
    [self.tableView performSelector:@selector(reloadSectionIndexTitles) withObject:nil afterDelay:0.3];
//    [self.tableView reloadSectionIndexTitles];
}

#pragma mark - ModalTextView

- (void)deleteTextView:(NSNotification *)notification {
    if (editingObject) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
        editingObject = nil;
    }
    
    [textView dismiss];
    textView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
}

- (void)dismissTextView:(NSNotification *)notification {
    if (editingObject) {
        NoteContent *object = editingObject;
        [object setData:[textView.textView.text dataUsingEncoding:NSUTF8StringEncoding]];
        [self.managedObjectContext save:nil];
        editingObject = nil;
    }
    else {
        //Neue Text-Notiz erstellen
        NoteContent *newContent = [self neuerNoteContentInNote:editNote];
        [newContent setDataType:@"text"];
        
        NSData* data = [textView.textView.text dataUsingEncoding:NSUTF8StringEncoding];
        [newContent setData:data];
        
        [self.managedObjectContext save:nil];
    }
    
    [textView dismiss];
    textView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - ModalImageView

- (void)takePhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentViewController:picker animated:YES completion:NULL];
    }
    else {
        // TODO alert, no camera available
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if (imageView) {
        [imageView updateImage:chosenImage];
    }
    else {
        // Neuen Inhalt erstellen
        NoteContent *newContent = [self neuerNoteContentInNote:editNote];
        [newContent setDataType:@"image"];
        
        NSData* data = UIImageJPEGRepresentation(chosenImage, 0.9);
        [newContent setData:data]; //TODO? : evtl. in async Block
        
        [self.managedObjectContext save:nil];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)deleteImageView:(NSNotification *)notification {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [imageView dismiss];
    imageView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    editingObject = nil;
}

- (void)dismissImageView:(NSNotification *)notification {
    NoteContent *object = editingObject;
    [self.tableView setUserInteractionEnabled:YES];
    
    if (imageView.didTakePhoto) {
        ImageCell *cell = (ImageCell *)[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
        cell.imageView.image = imageView.imageView.image;
        
        NSData* data = UIImageJPEGRepresentation(imageView.imageView.image, 0.9);
        [object setData:data]; //TODO? : evtl. in async Block
        
        
        [self.managedObjectContext save:nil];
    }
    
    [imageView dismiss];
    imageView = nil;
    [self resetBarButtonItems];
    [self.tableView setScrollEnabled:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    editingObject = nil;
}

#pragma mark - ModalMapView

- (void)dismissMapView {
    NoteContent *object = editingObject;
    [self.tableView setUserInteractionEnabled:YES];
    
    NSData* data = [NSData dataWithBytes:&tempCoordinate length:sizeof(tempCoordinate)];
    [object setData:data];
    [self.managedObjectContext save:nil];
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
}

- (void)openLocationInMaps {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Möchten Sie die App verlassen?" delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:@"In Karten öffnen" otherButtonTitles:nil, nil];
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
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
             // transitioning to landscape
             [imageView moveToLandscapeWithSize:size];
             [self.navigationController setNavigationBarHidden:YES animated:YES];
         }
         else {
             // transitioning to portrait
             [imageView moveToPortraitWithSize:size];
             [self.navigationController setNavigationBarHidden:NO animated:YES];
         }
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
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
    if (imageView) {
        return YES;
    }
    return NO;
}

@end