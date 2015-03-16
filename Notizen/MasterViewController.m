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
    cell.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    [self resetBarButtonItems];
    self.detailViewController = (ContainerViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self handleAppearance];
}

- (void)resetBarButtonItems {
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    observe(self, @selector(updateUserInterface), @"updateUserInterface");
    observe(self, @selector(dropReferencesToManagedObjects), @"dropReferencesToManagedObjects");
    observe(self, @selector(enableUserInteraction), @"enableUserInteraction");
    observe(self, @selector(disableUserInteraction), @"disableUserInteraction");
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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

- (void)insertNewObject:(id)sender {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissNewObjectStuffAndMoveToObject:)];
    self.navigationItem.rightBarButtonItems = @[];
    
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
    [context save:nil];
    
//    ContainerViewController *controller = (ContainerViewController *)[[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Detail"] topViewController];
//    [controller setContainer:(NoteContainer *)newManagedObject];
//    [controller setManagedObjectContext:self.managedObjectContext];
//    [controller setTitle:[newManagedObject valueForKey:@"title"]];
//    controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//    controller.navigationItem.leftItemsSupplementBackButton = YES;
//    [self.navigationController pushViewController:controller animated:YES];
    
    [self dismissNewObjectStuffAndMoveToObject:newManagedObject];
}

- (void)dismissNewObjectStuffAndMoveToObject:(NoteContainer *)object {
    [myTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat width = self.tableView.frame.size.width;
        CGFloat height = self.tableView.frame.size.height;
        
        [self.tableView setFrame:CGRectMake(0, 0, width, height)];
        [myTextField setFrame:CGRectMake(self.view.frame.size.width, 64 + (self.view.frame.size.height-64-250)/2-30, self.view.frame.size.width-80, 60)];
        [acceptButton setFrame:CGRectMake(self.view.frame.size.width+self.view.frame.size.width-80+5, 64 + (self.view.frame.size.height-64-250)/2-30, 60, 60)];
    } completion:^(BOOL finished) {
        [myTextField removeFromSuperview];
        myTextField = nil;
        [acceptButton removeFromSuperview];
        acceptButton = nil;
    }];
    
    if (object) {
//        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:object];
//        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
//        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
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
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        ContainerViewController *controller = (ContainerViewController *)[[segue destinationViewController] topViewController];
        [controller setContainer:(NoteContainer *)object];
        [controller setManagedObjectContext:self.managedObjectContext];
        [controller setTitle:[object valueForKey:@"title"]];
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
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
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
    return NO;
}

@end
