//
//  ModalTextView.m
//  Notizen
//
//  Created by Johannes Körner on 05.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ModalTextView.h"
#import "StoreHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation ModalTextView

- (id)initWithText:(NSString *)aText {
    if (self = [super init]) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.textView.text = aText;
        self.textView.font = customMediumTableFont;
        self.textView.textColor = [UIColor whiteColor];
        self.textView.textAlignment = NSTextAlignmentJustified;
        [self.textView setBackgroundColor:customTintColorWithAlpha(0.9)];
        [self.textView.layer setOpacity:0.0];
        self.dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.dimView setUserInteractionEnabled:YES];
        self.offset = 0;
        [self setBackgroundColor:[UIColor clearColor]];
        observe(self, @selector(getKeyBoardHeight:), UIKeyboardWillShowNotification);
    }
    return self;
}

- (void)getKeyBoardHeight:(NSNotification *)notification {
    removeObserver(self);
    observe(self, @selector(getKeyBoardHeight:), UIKeyboardDidChangeFrameNotification);
    
    CGRect rect = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect windowRect    = [self.window convertRect:rect fromWindow:nil];
    CGRect viewRect      = [self convertRect:windowRect fromView:nil];
    
    [self.dimView.layer setOpacity:0.3];
    [self.textView.layer setOpacity:1.0];
    [self.textView setFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-64-10-viewRect.size.height)];
}

- (void)showFromFrame:(CGRect)aTextViewFrame onTopOfView:(UIView *)aView {
    [self setFrame:CGRectMake(0, self.offset, aView.frame.size.width, aView.frame.size.height)];
    [aView addSubview:self];
    
    startingFrame = aTextViewFrame;
    
    [self.textView setFrame:aTextViewFrame];
    [self.textView.layer setMasksToBounds:YES];
    [self.textView.layer setCornerRadius:5];
    
    [self.dimView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.dimView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [self.dimView.layer setOpacity:0.0];
    
    [self addSubview:self.dimView];
    [self addSubview:self.textView];
    
    [self.textView becomeFirstResponder];
}

- (void)dismiss {
    removeObserver(self);
    [self.textView resignFirstResponder];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18]};
    CGRect rect = [self.textView.text boundingRectWithSize:CGSizeMake(startingFrame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGFloat height = rect.size.height+4;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.textView setFrame:CGRectMake(startingFrame.origin.x,
                                           startingFrame.origin.y,
                                           startingFrame.size.width,
                                           MAX(height+10, 44.0))];
        [self.textView.layer setOpacity:0.0];
        [self.dimView.layer setOpacity:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
