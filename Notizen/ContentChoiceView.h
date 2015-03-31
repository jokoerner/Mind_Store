//
//  ContentChoiceView.h
//  Notizen
//
//  Created by Johannes Körner on 11.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ScaleButton.h"

@interface ContentChoiceView : UIView <AVAudioRecorderDelegate> {
    CGRect endFrame;
    CGRect startFrame;
    
    UIView *dimView;
    
    UIView *kreisView;
    UIView *kreisWhite;
    UIView *kreisBlack;
    UIView *fakeKreisRed;
    UIButton *kreisRed;
    AVAudioRecorder *recorder;
    NSString *recorderFilePath;
    
    ScaleButton *textButton;
    ScaleButton *audioButton;
    ScaleButton *photoButton;
    ScaleButton *locationButton;
}

- (id)initWithFrame:(CGRect)frame;

- (void)showInView:(UIView *)theView;
- (void)dismiss;

@end
