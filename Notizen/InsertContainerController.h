//
//  InsertContainerController.h
//  Notizen
//
//  Created by Johannes Körner on 30.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsertContainerController : UIViewController <UITextFieldDelegate> {
    UILabel *myLabel;
    UITextField *myTextField;
    UIButton *acceptButton;
}

@property (nonatomic) BOOL canCancel;

@end
