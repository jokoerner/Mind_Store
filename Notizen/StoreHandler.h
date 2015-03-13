//
//  StoreHandler.h
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>

#define post(name) [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil]
#define postWithObject(name, anObject) [[NSNotificationCenter defaultCenter] postNotificationName:name object:anObject]
#define observe(who, sel, nam) [[NSNotificationCenter defaultCenter] addObserver:who selector:sel name:nam object:nil]
#define removeObserver(who) [[NSNotificationCenter defaultCenter] removeObserver:who]
#define removeObserverForName(who, theName) [[NSNotificationCenter defaultCenter] removeObserver:who name:theName object:nil]

#define iPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define iPhone ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)

#define customBackgroundColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]]
#define setBackgroundForView(theView) [theView insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]] atIndex:0]
#define customTableFont [UIFont fontWithName:@"HelveticaNeue-Light" size:22]
#define customMediumTableFont [UIFont fontWithName:@"HelveticaNeue-Light" size:20]
#define customSmallTableFont [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define customTintColor [UIColor colorWithHue:186.0/360.0 saturation:0.93 brightness:0.58 alpha:1.0]
#define customTintColorWithAlpha(myAlpha) [UIColor colorWithHue:186.0/360.0 saturation:0.93 brightness:0.58 alpha:myAlpha]
#define customBottomColor [UIColor colorWithRed:0.65 green:0.71 blue:0.58 alpha:1]

#define getDefault(key) [[NSUserDefaults standardUserDefaults] valueForKey:key]
#define setDefault(value, key) [[NSUserDefaults standardUserDefaults] setValue:value forKey:key]

@interface StoreHandler : NSObject

+ (id)shared;
- (void)stopAudio;

@property (strong) AVAudioPlayer *sharedAudioPlayer;

@end
