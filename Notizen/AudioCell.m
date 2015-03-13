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
}

- (void)layoutSubviews {
    [self updateProgress];
    [progressLabel setFrame:CGRectMake(50, 5, 50, 50)];
    [slider setFrame:CGRectMake(100, 5, self.frame.size.width-105, 50)];
    [playPauseButton setFrame:CGRectMake(5, 10, 40, 40)];
    
    if (![self.subviews containsObject:playPauseButton]) [self addSubview:playPauseButton];
    if (![self.subviews containsObject:progressLabel]) [self addSubview:progressLabel];
    if (![self.subviews containsObject:slider]) [self addSubview:slider];
}

- (void)initWithAudioData:(NSData *)audioData {
    NSError *error;
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
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
