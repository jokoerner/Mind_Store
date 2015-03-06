//
//  RotationSplitViewController.m
//  Notizen
//
//  Created by Johannes Körner on 06.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "RotationSplitViewController.h"
#import "StoreHandler.h"

@interface RotationSplitViewController ()

@end

@implementation RotationSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    if (iPhone) {
        return [self.viewControllers[0] supportedInterfaceOrientations];
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

//- (BOOL)shouldAutorotate {
//    //return [self.topViewController shouldAutorotate];
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    //return [self.topViewController preferredInterfaceOrientationForPresentation];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
