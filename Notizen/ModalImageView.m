//
//  ModalImageView.m
//  Notizen
//
//  Created by Johannes Körner on 10.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ModalImageView.h"
#import "StoreHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation ModalImageView

- (id)initWithImage:(UIImage *)anImage {
    if (self = [super init]) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.scrollView setDelegate:self];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor clearColor];
        [self.imageView.layer setOpacity:0.0];
        [self.imageView setImage:anImage];
        self.dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.dimView setUserInteractionEnabled:YES];
        self.offset = 0;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
}

- (void)updateImage:(UIImage *)anImage {
    //if (anImage != self.imageView.image) {
        [self.imageView setImage:anImage];
        self.didTakePhoto = YES;
    //}
}

- (void)moveToLandscapeWithSize:(CGSize)size {
    CGRect deviceBounds = [[UIScreen mainScreen] bounds];
    CGSize newSize = CGSizeMake(deviceBounds.size.width, deviceBounds.size.height);
    [self.dimView setFrame:CGRectMake(0, -64, newSize.width, newSize.height)];
    [self.imageView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
    [self.scrollView setFrame:CGRectMake(0, -64, newSize.width, newSize.height)];
    [self.scrollView setContentSize:newSize];
}

- (void)moveToPortraitWithSize:(CGSize)size {
    [self.dimView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.imageView setFrame:CGRectMake(5, 5, size.width-10, size.height-64-10)];
    [self.scrollView setFrame:CGRectMake(5, 5, size.width-10, size.height-64-10)];
    [self.scrollView setContentSize:self.imageView.frame.size];
}

- (void)showFromFrame:(CGRect)aTextViewFrame onTopOfView:(UIView *)aView {
    [self setFrame:CGRectMake(0, self.offset, aView.frame.size.width, aView.frame.size.height)];
    [aView addSubview:self];
    
    startingFrame = aTextViewFrame;
    
    [self.imageView setFrame:aTextViewFrame];
    
    [self.scrollView.layer setMasksToBounds:YES];
    [self.scrollView.layer setCornerRadius:5];
    
    [self.dimView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.dimView setBackgroundColor:[UIColor blackColor]];
    [self.dimView.layer setOpacity:0.0];
    
    [self addSubview:self.dimView];
    [self addSubview:self.imageView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.dimView.layer setOpacity:0.3];
        [self.imageView.layer setOpacity:1.0];
        [self.imageView setFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-64-10)];
    } completion:^(BOOL finished) {
        [self.scrollView setFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-64-10)];
        [self.imageView removeFromSuperview];
        CGSize imageSize = self.imageView.image.size;
        CGSize imageViewSize = CGSizeMake(self.frame.size.width-10,
                                          imageSize.height * (self.frame.size.width-10) / imageSize.width);
        [self.imageView setFrame:CGRectMake(0,
                                            (self.frame.size.height-10-64-imageViewSize.height)/2.0,
                                            imageViewSize.width,
                                            imageViewSize.height)];
        [self.scrollView addSubview:self.imageView];
        [self.scrollView setContentSize:self.imageView.frame.size];
        [self.scrollView setMaximumZoomScale:3.0];
        [self addSubview:self.scrollView];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        [self.imageView setFrame:startingFrame];
        [self.imageView.layer setOpacity:0.0];
        [self.dimView.layer setOpacity:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
