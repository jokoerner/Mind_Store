//
//  TextCell.h
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextCell : UITableViewCell {
    UIButton *addButton;
}

@property (strong) UITextView *noteTextView;
@property (nonatomic) BOOL muchEditing;

@end
