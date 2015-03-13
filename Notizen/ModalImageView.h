//
//  ModalImageView.h
//  Notizen
//
//  Created by Johannes Körner on 10.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalImageView : UIView<UIScrollViewDelegate> {
    CGRect startingFrame;
}

@property (strong) UIImageView *imageView;
@property (strong) UIScrollView *scrollView;
@property (strong) UIView *dimView;
@property (nonatomic) CGFloat offset;
@property (nonatomic) BOOL didTakePhoto;

- (id)initWithImage:(UIImage *)anImage;;
- (void)showFromFrame:(CGRect)anImageViewFrame onTopOfView:(UIView *)aView;
- (void)updateImage:(UIImage *)anImage;
- (void)dismiss;

- (void)moveToLandscapeWithSize:(CGSize)size;
- (void)moveToPortraitWithSize:(CGSize)size;

@end
