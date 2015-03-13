//
//  ImageCell.m
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell

- (void)awakeFromNib {
    // Initialization code
    self.noteImageView = [[UIImageView alloc] initWithFrame:CGRectNull];
    self.noteImageView.layer.masksToBounds = YES;
    self.noteImageView.layer.cornerRadius = 5;
    self.noteImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)layoutSubviews {
    if (![self.subviews containsObject:self.noteImageView]) [self addSubview:self.noteImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
