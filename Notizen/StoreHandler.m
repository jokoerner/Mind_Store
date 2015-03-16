//
//  StoreHandler.m
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "StoreHandler.h"

@implementation StoreHandler

+ (id)shared {
    static StoreHandler *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)stopAudio {
    [self.sharedAudioPlayer stop];
    self.sharedAudioPlayer = nil;
}

- (UIButton *)newAddStuffButton {
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [accessoryButton setImage:[UIImage imageNamed:@"Go"] forState:UIControlStateNormal];
    [accessoryButton setBackgroundColor:[UIColor whiteColor]];
    accessoryButton.layer.masksToBounds = YES;
    accessoryButton.layer.cornerRadius = 5.0;
    [accessoryButton.layer setOpacity:0.8];
    return accessoryButton;
}

@end
