//
//  TextCell.m
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "TextCell.h"


@implementation TextCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.noteTextView = [[UITextView alloc] initWithFrame:CGRectNull];
    [self.noteTextView setFont:[UIFont systemFontOfSize:18]];
    [self.noteTextView setBackgroundColor:[UIColor clearColor]];
    [self.noteTextView setTextAlignment:NSTextAlignmentJustified];
    [self.noteTextView setUserInteractionEnabled:NO];
}

- (void)layoutSubviews {
    NSString* text = self.noteTextView.text;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:20]};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.frame.size.width-10, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGFloat height = rect.size.height;
    if (height <= 44.0) [self.noteTextView setFont:[UIFont systemFontOfSize:20]];
    
    if (![self.subviews containsObject:self.noteTextView]) [self addSubview:self.noteTextView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
