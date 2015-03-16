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
    
    textButton = [[UIButton alloc] initWithFrame:CGRectMake(15,
                                                                      15,
                                                                      width/3.0,
                                                                      height/3.0)];
    [textButton setImage:[UIImage imageNamed:@"Compose"] forState:UIControlStateNormal];
    [textButton addTarget:self action:@selector(compose) forControlEvents:UIControlEventTouchUpInside];
    
    photoButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3.0*2.0-15,
                                                                       15,
                                                                       width/3.0,
                                                                       height/3.0)];
    [photoButton setImage:[UIImage imageNamed:@"Photo"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(photo) forControlEvents:UIControlEventTouchUpInside];
    
    audioButton = [[UIButton alloc] initWithFrame:CGRectMake(15,
                                                                        height/3.0*2.0-15,
                                                                        width/3.0,
                                                                        height/3.0)];
    [audioButton setImage:[UIImage imageNamed:@"Audio"] forState:UIControlStateNormal];
    [audioButton addTarget:self action:@selector(audio) forControlEvents:UIControlEventTouchUpInside];
    
    locationButton = [[UIButton alloc] initWithFrame:CGRectMake(width/3.0*2.0-15,
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
    if (recorder.isRecording) {
        [self cancelRecording];
        return;
    }
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
    [self prepareForRecordingAudio];
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

#pragma mark - Audio Recording

- (void)prepareForRecordingAudio {
    kreisView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, endFrame.size.width, endFrame.size.height)];
    kreisWhite = [[UIView alloc] initWithFrame:CGRectMake(15, 15, endFrame.size.width-30, endFrame.size.height-30)];
    kreisBlack = [[UIView alloc] initWithFrame:CGRectMake(25, 25, endFrame.size.width-50, endFrame.size.height-50)];
    kreisRed = [[UIButton alloc] initWithFrame:CGRectMake(endFrame.size.width/3.0, endFrame.size.height/3.0, endFrame.size.width/3.0, endFrame.size.height/3.0)];
    fakeKreisRed = [[UIButton alloc] initWithFrame:CGRectMake(endFrame.size.width/3.0, endFrame.size.height/3.0, endFrame.size.width/3.0, endFrame.size.height/3.0)];
    
    [kreisWhite setBackgroundColor:[UIColor whiteColor]];
    [kreisBlack setBackgroundColor:[UIColor blackColor]];
    [fakeKreisRed setBackgroundColor:[UIColor redColor]];
    
    kreisView.layer.opacity = 0.0;
    [kreisView addSubview:kreisWhite];
    [kreisView addSubview:kreisBlack];
    [kreisView addSubview:fakeKreisRed];
    [kreisView addSubview:kreisRed];
    [self addSubview:kreisView];
    
    kreisWhite.layer.masksToBounds = YES;
    kreisWhite.layer.cornerRadius = (endFrame.size.width-30.0)/2.0;
    kreisBlack.layer.masksToBounds = YES;
    kreisBlack.layer.cornerRadius = (endFrame.size.width-50.0)/2.0;
    fakeKreisRed.layer.masksToBounds = YES;
    fakeKreisRed.layer.cornerRadius = 10.0;
    
    [kreisRed addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect tempFrame;
        
        tempFrame = audioButton.frame;
        tempFrame.origin.x -= tempFrame.size.width+15;
        tempFrame.origin.y += tempFrame.size.height+15;
        [audioButton setFrame:tempFrame];
        
        tempFrame = textButton.frame;
        tempFrame.origin.x -= tempFrame.size.width+15;
        tempFrame.origin.y -= tempFrame.size.height+15;
        [textButton setFrame:tempFrame];
        
        tempFrame = photoButton.frame;
        tempFrame.origin.x += tempFrame.size.width+15;
        tempFrame.origin.y -= tempFrame.size.height+15;
        [photoButton setFrame:tempFrame];
        
        tempFrame = locationButton.frame;
        tempFrame.origin.x += tempFrame.size.width+15;
        tempFrame.origin.y += tempFrame.size.height+15;
        [locationButton setFrame:tempFrame];
        
        kreisView.layer.opacity = 1.0;
    } completion:^(BOOL finished) {
        [audioButton removeFromSuperview];
        [textButton removeFromSuperview];
        [photoButton removeFromSuperview];
        [locationButton removeFromSuperview];
        
        audioButton = nil;
        textButton = nil;
        photoButton = nil;
        locationButton = nil;
        
        [dimView setBackgroundColor:[UIColor redColor]];
        
        [self startRecording];
    }];
}

- (void)finishRecording {
    
}

#define DOCUMENTS_FOLDER NSTemporaryDirectory()


- (void) startRecording{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    if (getDefault(@"recordQualityVoice")) {
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    }
    else {
        //[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    }
    
//    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    
    // Create a new dated file
    recorderFilePath = [NSString stringWithFormat:@"%@/%@", DOCUMENTS_FOLDER, @"tempRecording"];
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    // start recording
    [recorder record];
    [self blink1];
}

- (void)blink1 {
    if (!recorder.isRecording) {
        return;
    }
    CGRect frame = fakeKreisRed.frame;
    frame.origin.x -= 10.0;
    frame.origin.y -= 10.0;
    frame.size.width += 20.0;
    frame.size.height += 20.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        [fakeKreisRed setFrame:frame];
    } completion:^(BOOL finished) {
        [self blink2];
    }];
}

- (void)blink2 {
    if (!recorder.isRecording) {
        return;
    }
    CGRect frame = fakeKreisRed.frame;
    frame.origin.x += 10.0;
    frame.origin.y += 10.0;
    frame.size.width -= 20.0;
    frame.size.height -= 20.0;
    
    [UIView animateWithDuration:0.5 animations:^{
        [fakeKreisRed setFrame:frame];
    } completion:^(BOOL finished) {
        [self blink1];
    }];
}

- (void) stopRecording{
    
    [recorder stop];
    
    NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
    NSError *err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(!audioData)
        NSLog(@"audio data: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    
    postWithObject(@"ContentChoiceViewAudio", [NSData dataWithContentsOfURL:url]);
    
    //[recorder deleteRecording];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    err = nil;
    [fm removeItemAtPath:[url path] error:&err];
    if(err)
        NSLog(@"File Manager: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    
    [self cancel];
}

- (void)cancelRecording {
    [recorder stop];
    
    NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *err = nil;
    [fm removeItemAtPath:[url path] error:&err];
    if(err)
        NSLog(@"File Manager: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    
    [self cancel];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    //NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    dimView.backgroundColor = [UIColor blackColor];
}

@end
