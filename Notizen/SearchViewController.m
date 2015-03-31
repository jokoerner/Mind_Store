//
//  SearchViewController.m
//  Notizen
//
//  Created by Johannes Körner on 28.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "SearchViewController.h"
#import "StoreHandler.h"
#import "NoteContainer.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self handleAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [object valueForKey:@"title"];
    [self handleCellAppearance:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    postWithObject(@"selectedObjectFromSearch", [self.searchResults objectAtIndex:indexPath.row]);
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self moveToNewOrientation];
}

- (void)moveToNewOrientation {
    UIImageView *background = [self.navigationController.view.subviews objectAtIndex:0];
    [background setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height-64)];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    
}

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
