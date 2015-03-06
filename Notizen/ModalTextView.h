//
//  ModalTextView.h
//  Notizen
//
//  Created by Johannes Körner on 05.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalTextView : UIView {
    CGRect startingFrame;
}

@property (strong) UITextView *textView;
@property (strong) UIView *dimView;
@property (nonatomic) CGFloat offset;

- (id)initWithText:(NSString *)aText;;
- (void)showFromFrame:(CGRect)aTextViewFrame onTopOfView:(UIView *)aView;
- (void)dismiss;

@end
