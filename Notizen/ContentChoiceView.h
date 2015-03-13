//
//  ContentChoiceView.h
//  Notizen
//
//  Created by Johannes Körner on 11.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentChoiceView : UIView {
    CGRect endFrame;
    CGRect startFrame;
    
    UIView *dimView;
}

- (id)initWithFrame:(CGRect)frame;

- (void)showInView:(UIView *)theView;
- (void)dismiss;

@end
