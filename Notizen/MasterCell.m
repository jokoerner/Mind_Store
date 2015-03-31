//
//  MasterCell.m
//  Notizen
//
//  Created by Johannes Körner on 29.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "MasterCell.h"

@implementation MasterCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    }
    else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //[super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    }
    else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

@end
