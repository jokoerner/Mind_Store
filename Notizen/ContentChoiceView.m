//
//  ContentChoiceView.m
//  Notizen
//
//  Created by Johannes Körner on 11.03.115.
//  Copyright (c) 20115 Johannes Körner. All rights reserved.
//

#import "ContentChoiceView.h"
#import "StoreHandler.h"

@implementation ContentChoiceView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        endFrame = frame;
        dimView = [[UIView alloc] initWithFrame:CGRectNull];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
        [dimView addGestureRecognizer:tap];
    }
    return self;
}

- (void)drawInterface {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 35;
    self.backgroundColor = customTintColorWithAlpha(1.0);
    self.layer.opacity = 0.0;
    
    dimView.backgroundColor = [UIColor blackColor];
    dimView.layer.opacity = 0.0;
    
    CGFloat width = endFrame.size.width;
    CGFloat height = endFrame.size.height;
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3.0,
                                                                        height/3.0,
                                                                        width/3.0,
                                                                        height/3.0)];
    [cancelButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *textButton = [[UIButton alloc] initWithFrame:CGRectMake(15,
                                                                      15,
                                                                      width/3.0,
                                                                      height/3.0)];
    [textButton setImage:[UIImage imageNamed:@"Compose"] forState:UIControlStateNormal];
    [textButton addTarget:self action:@selector(compose) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *photoButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3.0*2.0-15,
                                                                       15,
                                                                       width/3.0,
                                                                       height/3.0)];
    [photoButton setImage:[UIImage imageNamed:@"Photo"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(photo) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *audioButton = [[UIButton alloc] initWithFrame:CGRectMake(15,
                                                                        height/3.0*2.0-15,
                                                                        width/3.0,
                                                                        height/3.0)];
    [audioButton setImage:[UIImage imageNamed:@"Audio"] forState:UIControlStateNormal];
    [audioButton addTarget:self action:@selector(audio) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *locationButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3.0*2.0-15,
                                                                          height/3.0*2.0-15,
                                                                          width/3.0,
                                                                          height/3.0)];
    [locationButton setImage:[UIImage imageNamed:@"Location"] forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(location) forControlEvents:UIControlEventTouchUpInside];
    
    //[self addSubview:cancelButton];
    [self addSubview:textButton];
    [self addSubview:photoButton];
    [self addSubview:audioButton];
    [self addSubview:locationButton];
}

- (void)cancel {
    [self dismiss];
    post(@"ContentChoiceViewDidDismiss");
}

- (void)compose {
    post(@"ContentChoiceViewCompose");
    [self cancel];
}

- (void)photo {
    post(@"ContentChoiceViewPhoto");
    [self cancel];
}

- (void)audio {
    //post(@"ContentChoiceViewAudio");
}

- (void)location {
    post(@"ContentChoiceViewLocation");
    [self cancel];
}

- (void)showInView:(UIView *)theView {
    [self drawInterface];
    
    CGFloat width = theView.frame.size.width;
    CGFloat height = theView.frame.size.height;
    
    dimView.frame = CGRectMake(0, 0, width, height);
    [theView addSubview:dimView];
    
    self.frame = CGRectMake(endFrame.origin.x, -endFrame.size.height, endFrame.size.width, endFrame.size.height);
    startFrame = self.frame;
    [theView addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = endFrame;
        self.layer.opacity = 1.0;
        dimView.layer.opacity = 0.3;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = startFrame;
        self.layer.opacity = 0.0;
        dimView.layer.opacity = 0.0;
    } completion:^(BOOL finished) {
        [dimView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
