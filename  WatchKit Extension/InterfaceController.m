//
//  InterfaceController.m
//   WatchKit Extension
//
//  Created by Johannes Körner on 18.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    timeStamp = [NSDate distantPast];
    addToLast = NO;
}

- (IBAction)markLocation:(id)sender {
    if ([[NSDate date] timeIntervalSinceDate:timeStamp] < 4) {
        addToLast = YES;
    }
    else {
        addToLast = NO;
    }
    NSArray* initialPhrases = @[NSLocalizedString(@"Beautiful View", nil), NSLocalizedString(@"Nice Place", nil), NSLocalizedString(@"Great Food", nil)];
    [self presentTextInputControllerWithSuggestions:initialPhrases
                                   allowedInputMode:WKTextInputModePlain
                                         completion:^(NSArray *results) {
                                             NSString *aResult = @"";
                                             if (results.count > 0) aResult = [results lastObject];
                                             
                                             [WKInterfaceController openParentApplication:@{@"action" : @"saveLocation", @"info" : aResult, @"addToLast" : @(addToLast)} reply:^(NSDictionary *replyInfo, NSError *error) {
                                                 NSString *anError = [replyInfo valueForKey:@"error"];
                                                 if (anError.length > 0 && ![anError isEqualToString:@"NO"]) {
                                                     //rote Animation
                                                     if ([anError isEqualToString:@"LocationServicesError"]) {
                                                         [self presentControllerWithName:@"LocationServicesError" context:nil];
                                                     }
                                                     [self failedAnimation];
                                                 }
                                                 else {
                                                     //grüne Animation
                                                     [self successAnimationWithDuration:@(3)];
                                                     timeStamp = [NSDate date];
                                                 }
                                             }];
                                         }];
}

- (IBAction)writeNote:(id)sender {
    //NSArray* initialPhrases = @[@"Great View", @"Nice Place", @"Great Food"];
    if ([[NSDate date] timeIntervalSinceDate:timeStamp] < 4) {
        addToLast = YES;
    }
    else {
        addToLast = NO;
    }
    [self presentTextInputControllerWithSuggestions:nil
                                   allowedInputMode:WKTextInputModePlain
                                         completion:^(NSArray *results) {
                                             NSString *aResult = @"";
                                             if (results.count > 0) aResult = [results lastObject];
                                             
                                             [WKInterfaceController openParentApplication:@{@"action" : @"saveNote", @"info" : aResult, @"addToLast" : @(addToLast)} reply:^(NSDictionary *replyInfo, NSError *error) {
                                                 NSString *anError = [replyInfo valueForKey:@"error"];
                                                 if (anError.length > 0 && ![anError isEqualToString:@"NO"]) {
                                                     //rote Animation
                                                     [self failedAnimation];
                                                 }
                                                 else {
                                                     //grüne Animation
                                                     [self successAnimationWithDuration:@(3)];
                                                     timeStamp = [NSDate date];
                                                 }
                                             }];
                                         }];
}


- (void)setGreen {
    [self.separator setColor:[UIColor colorWithRed:0.4 green:1.0 blue:0.4 alpha:1.0]];
}

- (void)setRed {
    [self.separator setColor:[UIColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0]];
}

- (void)setWhite {
    [self.separator setColor:[UIColor whiteColor]];
}

- (void)setBlue {
    [self.separator setColor:[UIColor blueColor]];
}

- (void)failedAnimation {
    [self setRed];
    [self performSelector:@selector(setWhite) withObject:nil afterDelay:1.0];
}

- (void)successAnimationWithDuration:(NSNumber *)duration {
    if (duration.integerValue == 0) {
        [self setGreen];
        [self performSelector:@selector(setWhite) withObject:nil afterDelay:1.0];
    }
    else if (duration.integerValue > 1) {
        [self setGreen];
        [self performSelector:@selector(setWhite) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(successAnimationWithDuration:) withObject:@(duration.integerValue-1) afterDelay:1.0];
    }
    else if (duration.integerValue == 1) {
        [self setGreen];
        [self performSelector:@selector(setWhite) withObject:nil afterDelay:0.25];
        [self performSelector:@selector(setBlue) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(setWhite) withObject:nil afterDelay:1.0];
    }
}

- (void)buttonNormal {
    [self.markLocationButton setBackgroundImageNamed:@"Location"];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



