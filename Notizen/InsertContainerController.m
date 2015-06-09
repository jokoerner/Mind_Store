//
//  InsertContainerController.m
//  Notizen
//
//  Created by Johannes Körner on 30.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "InsertContainerController.h"
#import "StoreHandler.h"

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

@interface InsertContainerController ()

@end

@implementation InsertContainerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    setBackgroundForView(self.view);
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItems = @[];
    
    myLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, -70, self.view.frame.size.width-80, 40)];
    [myLabel setTextColor:[UIColor whiteColor]];
    [myLabel setFont:customTableFontOfSize(40)];
    [myLabel setText:NSLocalizedString(@"New Folder", nil)];
    [myLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:myLabel];
    
    myTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, -50, self.view.frame.size.width-80, 60)];
    [myTextField setTextColor:[UIColor whiteColor]];
    [myTextField setFont:customTableFontOfSize(30)];
    myTextField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    [myTextField.layer setMasksToBounds:YES];
    [myTextField.layer setCornerRadius:5];
    [myTextField setDelegate:self];
    [self.view addSubview:myTextField];
    
    acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 64 + (self.view.frame.size.height-64-250)/2-30, 60, 60)];
    [acceptButton addTarget:self action:@selector(accepted) forControlEvents:UIControlEventTouchUpInside];
    [acceptButton setImage:[UIImage imageNamed:@"Go"] forState:UIControlStateNormal];
    acceptButton.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    [self.view addSubview:acceptButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIImageView *background = [self.view.subviews objectAtIndex:0];
    [background setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    
    [myLabel setFrame:CGRectMake(5, 64, self.view.frame.size.width-10, (self.view.frame.size.height-64-250)/2-30)];
    [myTextField setFrame:CGRectMake(5, 64 + (self.view.frame.size.height-64-250)/2-30, self.view.frame.size.width-80, 60)];
    [myTextField becomeFirstResponder];
    [acceptButton setFrame:CGRectMake(self.view.frame.size.width-65, 64 + (self.view.frame.size.height-64-250)/2-30, 60, 60)];
}

- (void)accepted {
    if (myTextField.text.length > 0) {
        postWithObject(@"newContainer", myTextField.text);
    }
    [self dismiss];
}

- (void)cancel {
    if (self.canCancel) {
        [self dismiss];
    }
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self accepted];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
