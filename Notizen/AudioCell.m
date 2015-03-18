//
//  AudioCell.m
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "AudioCell.h"
#import "StoreHandler.h"

@implementation AudioCell

- (void)awakeFromNib {
    // Initialization code
    progressLabel = [[UILabel alloc] initWithFrame:CGRectNull];
    [progressLabel setTextColor:[UIColor whiteColor]];
    [progressLabel setFont:customMediumTableFont];
    
    slider = [[UISlider alloc] initWithFrame:CGRectNull];
    [slider setValue:0.0 animated:NO];
    [slider setThumbImage:[UIImage imageNamed:@"AudioSliderThumb"] forState:UIControlStateNormal];
    [slider setMinimumTrackTintColor:[UIColor colorWithRed:0.31 green:0.36 blue:0.45 alpha:1]];
    [slider addTarget:self action:@selector(setAudioProgress) forControlEvents:UIControlEventValueChanged];
    
    playPauseButton = [[UIButton alloc] initWithFrame:CGRectNull];
    [playPauseButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    [playPauseButton addTarget:self action:@selector(playPauseAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *accessoryButton = [[StoreHandler shared] newAddStuffButton];
    [accessoryButton addTarget:self action:@selector(accessoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setEditingAccessoryView:accessoryButton];
}

- (void)accessoryButtonAction:(UIButton *)sender {
    postWithObject(@"accessoryButtonAction", self);
}

- (void)layoutSubviews {
    [self updateProgress];
    [progressLabel setFrame:CGRectMake(50, 5, 50, 50)];
    [slider setFrame:CGRectMake(100, 5, self.frame.size.width-105, 50)];
    [playPauseButton setFrame:CGRectMake(5, 10, 40, 40)];
    
    if (![self.contentView.subviews containsObject:playPauseButton]) [self.contentView addSubview:playPauseButton];
    if (![self.contentView.subviews containsObject:progressLabel]) [self.contentView addSubview:progressLabel];
    if (![self.contentView.subviews containsObject:slider]) [self.contentView addSubview:slider];
    
    //[self moveSubviews];
    [super layoutSubviews];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [slider setUserInteractionEnabled:NO];
        [playPauseButton setUserInteractionEnabled:NO];
    }
    else {
        [slider setUserInteractionEnabled:YES];
        [playPauseButton setUserInteractionEnabled:YES];
    }
}

- (void)moveSubviews {
    if (self.editing && !_muchEditing) {
        _muchEditing = YES;
        for (UIView *aSubview in self.subviews) {
            CGRect oldFrame = aSubview.frame;
            oldFrame.origin.x += 35;
            [aSubview setFrame:oldFrame];
        }
    }
    else if (!self.editing && _muchEditing) {
        _muchEditing = NO;
        for (UIView *aSubview in self.subviews) {
            CGRect oldFrame = aSubview.frame;
            oldFrame.origin.x -= 35;
            [aSubview setFrame:oldFrame];
        }
    }
}

- (void)initWithAudioData:(NSData *)audioData {
    NSError *error;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    [player setDelegate:self];
    [player prepareToPlay];
}

- (void)setPlayButton {
    [playPauseButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
}

- (void)setPauseButton {
    [playPauseButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [timer invalidate];
    [self updateProgress];
    [self setPlayButton];
}

- (void)playPauseAudio:(UIBarButtonItem *)item {
    if (player != [[StoreHandler shared] sharedAudioPlayer]) {
        [[StoreHandler shared] stopAudio];
    }
    
    if (player.isPlaying) {
        [player pause];
        [self setPlayButton];
        [timer invalidate];
    }
    else {
        [player play];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                             target:self
                                                           selector:@selector(updateProgress)
                                                           userInfo:nil
                                                            repeats:YES];
        [self setPauseButton];
    }
}

- (void)resetAudio {
    [player setCurrentTime:0];
    [self updateProgress];
}

- (void)setAudioProgress {
    [player setCurrentTime:(player.duration * slider.value)];
    [self updateProgressLabel];
}

- (void)updateProgressLabel {
    int songLength = player.currentTime;
    int minutes = songLength / 60;
    int seconds = songLength % 60;
    NSString *lengthString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    progressLabel.text = lengthString;
}

- (void)updateProgress {
    [slider setValue:(player.currentTime / player.duration) animated:YES];
    [self updateProgressLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.editing) {
        [super setSelected:selected animated:animated];
        if (selected) {
            [progressLabel setTextColor:[UIColor blackColor]];
        }
        else {
            [progressLabel setTextColor:[UIColor whiteColor]];
        }
    }
}

@end
