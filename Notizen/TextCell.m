//
//  TextCell.m
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "TextCell.h"
#import "StoreHandler.h"

@implementation TextCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.noteTextView = [[UITextView alloc] initWithFrame:CGRectNull];
    [self.noteTextView setFont:customMediumTableFont];
    [self.noteTextView setTextColor:[UIColor whiteColor]];
    [self.noteTextView setBackgroundColor:[UIColor clearColor]];
    [self.noteTextView setTextAlignment:NSTextAlignmentJustified];
    [self.noteTextView setUserInteractionEnabled:NO];
    
    UIButton *accessoryButton = [[StoreHandler shared] newAddStuffButton];
    [accessoryButton addTarget:self action:@selector(accessoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setEditingAccessoryView:accessoryButton];
}

- (void)accessoryButtonAction:(UIButton *)sender {
    postWithObject(@"accessoryButtonAction", self);
}

- (void)layoutSubviews {
    NSString* text = self.noteTextView.text;
    NSDictionary *attributes = @{NSFontAttributeName: customTableFont};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGFloat height = rect.size.height;
    
    if (height <= 44.0) [self.noteTextView setFont:customTableFont];
    
    if (![self.contentView.subviews containsObject:self.noteTextView]) [self.contentView addSubview:self.noteTextView];
    
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
    if (self.editing && selected) {
        [self.noteTextView setTextColor:[UIColor blackColor]];
    }
    else if (self.editing && !selected) {
        [self.noteTextView setTextColor:[UIColor whiteColor]];
    }
}

@end
