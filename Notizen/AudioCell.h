//
//  AudioCell.h
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioCell : UITableViewCell <AVAudioPlayerDelegate> {
    UISlider *slider;
    AVAudioPlayer *player;
    UILabel *progressLabel;
    NSTimer *timer;
    
    UIButton *playPauseButton;
}

- (void)initWithAudioData:(NSData *)audioData;
@property (nonatomic) BOOL muchEditing;

@end
