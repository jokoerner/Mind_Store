//
//  ModalAudioRecorder.h
//  Notizen
//
//  Created by Johannes Körner on 16.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ModalAudioRecorder : UIView {
    CGRect startingFrame;
    NSURL *recordingURL;
    
    UIView *kreisView;
    UIView *kreisWhite;
    UIView *kreisBlack;
    UIButton *kreisRed;
}

@property (strong) AVAudioRecorder *recorder;
@property (strong) UIView *dimView;
@property (nonatomic) CGFloat offset;

- (id)initForRecording;
- (void)showFromFrame:(CGRect)aFrame onTopOfView:(UIView *)aView;
- (void)dismiss;

@end
