//
//  ScaleButton.m
//  Notizen
//
//  Created by Johannes Körner on 30.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ScaleButton.h"

@implementation ScaleButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return contentRect;
}

@end
