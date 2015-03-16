//
//  ImageCell.m
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ImageCell.h"
#import "StoreHandler.h"

@implementation ImageCell

- (void)awakeFromNib {
    // Initialization code
    self.noteImageView = [[UIImageView alloc] initWithFrame:CGRectNull];
    self.noteImageView.layer.masksToBounds = YES;
    self.noteImageView.layer.cornerRadius = 5;
    self.noteImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIButton *accessoryButton = [[StoreHandler shared] newAddStuffButton];
    [accessoryButton addTarget:self action:@selector(accessoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setEditingAccessoryView:accessoryButton];
}

- (void)accessoryButtonAction:(UIButton *)sender {
    postWithObject(@"accessoryButtonAction", self);
}

- (void)layoutSubviews {
    if (![self.contentView.subviews containsObject:self.noteImageView]) [self.contentView addSubview:self.noteImageView];
    
    //[self moveSubviews];
    [super layoutSubviews];
}

- (void)moveSubviews {
    if (self.editing && !_muchEditing) {
        _muchEditing = YES;
        for (UIView *aSubview in self.subviews) {
            CGRect oldFrame = aSubview.frame;
            oldFrame.origin.x += 35;
            [aSubview setFrame:oldFrame];
        }
    }
    else if (!self.editing && _muchEditing) {
        _muchEditing = NO;
        for (UIView *aSubview in self.subviews) {
            CGRect oldFrame = aSubview.frame;
            oldFrame.origin.x -= 35;
            [aSubview setFrame:oldFrame];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
