//
//  MasterViewController.m
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "MasterViewController.h"
#import "ContainerViewController.h"
#import "NoteContainer.h"
#import "Note.h"
#import "NoteContent.h"
#import "SearchViewController.h"
#import "InsertContainerController.h"

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if (iPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)handleAppearance {
    setBackgroundForView(self.navigationController.view);
    UIImageView *background = [self.navigationController.view.subviews objectAtIndex:0];
    [background setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height)];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    UIView *clearView = [[UIView alloc] initWithFrame:CGRectNull];
    [clearView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:clearView];
    self.tableView.sectionIndexBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    self.tableView.sectionIndexColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = customTintColor;
}

- (void)handleCellAppearance:(UITableViewCell *)cell {
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = customTableFont;
    cell.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    [self resetBarButtonItems];
    self.detailViewController = (ContainerViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self handleAppearance];
    [self initSearchBar];
    
    self.tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.frame.size.height);
    
    observe(self, @selector(newContainer:), @"newContainer");
    observe(self, @selector(selectFirstContainer), @"noContainer");
}

- (void)initSearchBar {
    // Create a mutable array to contain products for the search results table.
    self.searchResults = [NSMutableArray array];
    
    // The table view controller is in a nav controller, and so the containing nav controller is the 'search results controller'
    UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"searchNavCon"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
//    NSMutableArray *scopeButtonTitles = [[NSMutableArray alloc] init];
//    [scopeButtonTitles addObject:NSLocalizedString(@"All", @"Search display controller All button.")];
//    [scopeButtonTitles addObject:@"Test"];
//    
//    self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setTintColor:customTintColor];
    [self.searchController.searchBar setBarTintColor:[UIColor colorWithWhite:0.8 alpha:0.5]];
    
    self.definesPresentationContext = YES;
}

- (void)resetBarButtonItems {
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    removeObserver(self);
    observe(self, @selector(updateUserInterface), @"updateUserInterface");
    observe(self, @selector(dropReferencesToManagedObjects), @"dropReferencesToManagedObjects");
    observe(self, @selector(enableUserInteraction), @"enableUserInteraction");
    observe(self, @selector(disableUserInteraction), @"disableUserInteraction");
    observe(self, @selector(selectedObjectFromSearch:), @"selectedObjectFromSearch");
    observe(self, @selector(newContainer:), @"newContainer");
    observe(self, @selector(selectFirstContainer), @"noContainer");
    
    if (iPhone) [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)selectFirstContainer {
    
    if (iPad) {
        if (!self.tableView.indexPathForSelectedRow && !myTextField) {
            if (self.fetchedResultsController.fetchedObjects.count > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self performSegueWithIdentifier:@"showDetail" sender:self];
            }
            else {
                //Neu anlegen
                [self insertNewObject:nil];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUserInterface {
    [self.tableView reloadData];
}

- (void)dropReferencesToManagedObjects {
    _fetchedResultsController = nil;
}

- (void)enableUserInteraction {
    [self.view setUserInteractionEnabled:YES];
}

- (void)disableUserInteraction {
    [self.view setUserInteractionEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Neues Objekt erstellen

- (void)newContainer:(NSNotification *)notification {
    NSString *string = notification.object;
    [self insertNewObjectWithTitle:string];
}

- (void)insertNewObject:(id)sender {
    if (iPad) {
        InsertContainerController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"insertContainer"];
        vc.canCancel = (self.fetchedResultsController.fetchedObjects.count == 0) ? NO : YES;
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:vc];
        [navCon setModalPresentationStyle:UIModalPresentationFormSheet];
        [self.navigationController presentViewController:navCon animated:YES completion:nil];
        return;
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissNewObjectStuffAndMoveToObject:)];
    self.navigationItem.rightBarButtonItems = @[];
    
    myLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, -70, self.view.frame.size.width-80, 40)];
    [myLabel setTextColor:[UIColor whiteColor]];
    [myLabel setFont:customTableFontOfSize(40)];
    [myLabel setText:NSLocalizedString(@"New Folder", nil)];
    [myLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tableView.superview addSubview:myLabel];
    
    myTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, -50, self.view.frame.size.width-80, 60)];
    [myTextField setTextColor:[UIColor whiteColor]];
    [myTextField setFont:customTableFontOfSize(30)];
    myTextField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    [myTextField.layer setMasksToBounds:YES];
    [myTextField.layer setCornerRadius:5];
    [myTextField setDelegate:self];
    [self.tableView.superview addSubview:myTextField];
    
    acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 64 + (self.view.frame.size.height-64-250)/2-30, 60, 60)];
    [acceptButton addTarget:self action:@selector(accepted) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton setImage:[UIImage imageNamed:@"Go"] forState:UIControlStateNormal];
    acceptButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    [self.tableView.superview addSubview:acceptButton];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat width = self.tableView.frame.size.width;
        CGFloat height = self.tableView.frame.size.height;
        [self.tableView setFrame:CGRectMake(0, self.view.frame.size.height, width, height)];
        
        [myLabel setFrame:CGRectMake(5, 64, self.view.frame.size.width-10, (self.view.frame.size.height-64-250)/2-30)];
        [myTextField setFrame:CGRectMake(5, 64 + (self.view.frame.size.height-64-250)/2-30, self.view.frame.size.width-80, 60)];
    } completion:^(BOOL finished) {
        [myTextField becomeFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            [acceptButton setFrame:CGRectMake(self.view.frame.size.width-65, 64 + (self.view.frame.size.height-64-250)/2-30, 60, 60)];
        } completion:^(BOOL finished) {
            
        }];
    }];
    
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//        
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//        
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
}

- (void)accepted {
    if (myTextField.text.length > 0) {
        [self insertNewObjectWithTitle:myTextField.text];
    }
    else {
        [self dismissNewObjectStuffAndMoveToObject:nil];
    }
}

- (void)insertNewObjectWithTitle:(NSString *)theTitle {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContainer" inManagedObjectContext:context];
    NoteContainer *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setTitle:theTitle];
    
//    ContainerViewController *controller = (ContainerViewController *)[[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Detail"] topViewController];
//    [controller setContainer:(NoteContainer *)newManagedObject];
//    [controller setManagedObjectContext:self.managedObjectContext];
//    [controller setTitle:[newManagedObject valueForKey:@"title"]];
//    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//    controller.navigationItem.leftItemsSupplementBackButton = YES;
//    [self.navigationController pushViewController:controller animated:YES];
    
    [context save:nil];
    if (iPhone) [self dismissNewObjectStuffAndMoveToObject:newManagedObject];
}

- (void)dismissNewObjectStuffAndMoveToObject:(NoteContainer *)object {
    [myTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat width = self.tableView.frame.size.width;
        CGFloat height = self.tableView.frame.size.height;
        
        [self.tableView setFrame:CGRectMake(0, 0, width, height)];
        CGRect frame = myLabel.frame;
        frame.origin.x = self.view.frame.size.width;
        [myLabel setFrame:frame];
        [myTextField setFrame:CGRectMake(self.view.frame.size.width, 64 + (self.view.frame.size.height-64-250)/2-30, self.view.frame.size.width-80, 60)];
        [acceptButton setFrame:CGRectMake(self.view.frame.size.width+self.view.frame.size.width-80+5, 64 + (self.view.frame.size.height-64-250)/2-30, 60, 60)];
    } completion:^(BOOL finished) {
        [myTextField removeFromSuperview];
        myTextField = nil;
        [acceptButton removeFromSuperview];
        acceptButton = nil;
        [myLabel removeFromSuperview];
        myLabel = nil;
    }];
    
    if (object) {
        //tempIndexPath = [self.fetchedResultsController indexPathForObject:object];
    }
    
    [self resetBarButtonItems];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (myTextField.text.length > 0) {
        [self insertNewObjectWithTitle:myTextField.text];
    }
    else {
        [self dismissNewObjectStuffAndMoveToObject:nil];
    }
    return YES;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (!indexPath) {
            ContainerViewController *controller = (ContainerViewController *)[[segue destinationViewController] topViewController];
            [controller setManagedObjectContext:nil];
            controller.fetchedResultsController = nil;
            [controller setContainer:nil];
            [controller setTitle:@"Mind Store"];
            if (searchIndexPath) {
                controller.searchIndexPath = nil;
                searchIndexPath = nil;
            }
            controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
            controller.navigationItem.leftItemsSupplementBackButton = YES;
            return;
        }
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        ContainerViewController *controller = (ContainerViewController *)[[segue destinationViewController] topViewController];
        [controller setContainer:(NoteContainer *)object];
        [controller setManagedObjectContext:self.managedObjectContext];
        [controller setTitle:[object valueForKey:@"title"]];
        if (searchIndexPath) {
            controller.searchIndexPath = searchIndexPath;
            searchIndexPath = nil;
        }
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"forceShowDetail"]) {
        NSManagedObject *object = tempContainer;
        ContainerViewController *controller = (ContainerViewController *)[[segue destinationViewController] topViewController];
        [controller setContainer:(NoteContainer *)object];
        [controller setManagedObjectContext:self.managedObjectContext];
        [controller setTitle:[object valueForKey:@"title"]];
        if (searchIndexPath) {
            controller.searchIndexPath = searchIndexPath;
            searchIndexPath = nil;
        }
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NoteContainer *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (iPad) { //neuen Container auswählen
            NSArray *fetchedObjects = self.fetchedResultsController.fetchedObjects;
            if (fetchedObjects.count > 1) {
                NSInteger indexOfObject = [fetchedObjects indexOfObject:object];
                NoteContainer *newObject;
                if (fetchedObjects.count-1 > indexOfObject) {
                    newObject = [fetchedObjects objectAtIndex:indexOfObject+1];
                }
                else {
                    newObject = [fetchedObjects objectAtIndex:indexOfObject-1];
                }
                tempContainer = newObject;
                [self.tableView selectRowAtIndexPath:[self.fetchedResultsController indexPathForObject:newObject] animated:YES scrollPosition:UITableViewScrollPositionNone];
                [self performSegueWithIdentifier:@"forceShowDetail" sender:self];
            }
            else {
                NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
                if (selectedRow) [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
                [self performSegueWithIdentifier:@"showDetail" sender:self];
            }
        }
        [context deleteObject:object];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object valueForKey:@"title"];
    [self handleCellAppearance:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *array = [NSMutableArray array];
    NSInteger numberOfSections = [self numberOfSectionsInTableView:tableView];
    NSInteger totalNumberOfRows = 0;
    
    for (int i = 0; i < numberOfSections; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][i];
        [array addObject:[sectionInfo name]];
    }
    
    for (int i = 0; i < numberOfSections; i++) {
        totalNumberOfRows = totalNumberOfRows + [self tableView:tableView numberOfRowsInSection:i];
    }
    
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat tableHeight = totalNumberOfRows * 50.0;
    
    if (viewHeight < tableHeight && array.count > 1) {
        return array;
    }
    
    return [NSArray array];;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0) {
//        cell.backgroundView = topImageview;
//    }
//    else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
//        cell.backgroundView = botImageview;
//    }
//    else {
//        cell.backgroundView = midImageview;
//    }
//    
//    [cell setBackgroundColor:[UIColor clearColor]];
//    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
//    [cell.textLabel setTextColor:[UIColor whiteColor]];
//    [cell.textLabel setFont:[UIFont systemFontOfSize:22.0]];
//    cell.indentationWidth = 10.0;
//}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteContainer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:[getDefault(@"ascending") boolValue]];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetter" cacheName:nil];
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
            tempIndexPath = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
    if (tempIndexPath) {
        [self.tableView selectRowAtIndexPath:tempIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self performSegueWithIdentifier:@"showDetail" sender:self];
        tempIndexPath = nil;
    }
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

#pragma mark - Rotation

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    if (iPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    if (iPad) return YES;
    
    return NO;
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [self.searchController.searchBar text];
    
//    NSString *scope = nil;
    
//    NSInteger selectedScopeButtonIndex = [self.searchController.searchBar selectedScopeButtonIndex];
//    if (selectedScopeButtonIndex > 0) {
//        scope = @"Test";
//    }
    
    [self updateFilteredContentForNoteContent:searchString type:nil];
    
    if (self.searchController.searchResultsController) {
        UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
        
        SearchViewController *vc = (SearchViewController *)navController.topViewController;
        vc.searchResults = self.searchResults;
        [vc.tableView reloadData];
    }
    
}

#pragma mark - Search

- (void)selectedObjectFromSearch:(NSNotification *)notification {
    //IndexPath suchen
    NoteContainer *container = notification.object;
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:container];
    
    //Position der zur Suche passenden Notiz suchen
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creation.description" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor, sortDescriptor2];
    NSArray *noteObjekte = [container.notes.allObjects sortedArrayUsingDescriptors:sortDescriptors];
    NSIndexPath *indexPathOfNote;
    for (Note *note in noteObjekte) {
        for (NoteContent *content in note.noteContents) {
            if ([content.dataType isEqualToString:@"text"]) {
                //Text durchsuchen
                NSString *contentString = [[NSString alloc] initWithData:content.data encoding:NSUTF8StringEncoding];
                NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
                NSRange noteContentStringRange = NSMakeRange(0, contentString.length);
                NSRange foundRange = [contentString rangeOfString:self.searchController.searchBar.text options:searchOptions range:noteContentStringRange];
                if (foundRange.length > 0) {
                    [self.searchResults addObject:container];
                    indexPathOfNote = [NSIndexPath indexPathForRow:content.index.integerValue inSection:[noteObjekte indexOfObject:note]];
                    
                    //Transition
                    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    searchIndexPath = indexPathOfNote;
                    [self performSegueWithIdentifier:@"showDetail" sender:self];
                    [self.searchController setActive:NO];
                }
            }
        }
    }
}

#pragma mark - UISearchBarDelegate

// Workaround for bug: -updateSearchResultsForSearchController: is not called when scope buttons change
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}


#pragma mark - Content Filtering

- (void)updateFilteredContentForNoteContent:(NSString *)noteContentString type:(NSString *)typeName {
    // Update the filtered array based on the search text and scope.
    if ((noteContentString == nil) || [noteContentString length] == 0) {
        self.searchResults = [self.fetchedResultsController.fetchedObjects mutableCopy];
        return;
    }
    
    [self.searchResults removeAllObjects]; // First clear the filtered array.
    
    for (NoteContainer *container in self.fetchedResultsController.fetchedObjects) {
        BOOL containerAdded = NO;
        for (Note *note in container.notes) {
            for (NoteContent *content in note.noteContents) {
                if ([content.dataType isEqualToString:@"text"]) {
                    //Text durchsuchen
                    NSString *contentString = [[NSString alloc] initWithData:content.data encoding:NSUTF8StringEncoding];
                    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
                    NSRange noteContentStringRange = NSMakeRange(0, contentString.length);
                    NSRange foundRange = [contentString rangeOfString:noteContentString options:searchOptions range:noteContentStringRange];
                    if (foundRange.length > 0) {
                        [self.searchResults addObject:container];
                        containerAdded = YES;
                        break;
                    }
                }
                //evtl. Datum suchen
            }
            if (containerAdded) break;
        }
    }
}

@end
