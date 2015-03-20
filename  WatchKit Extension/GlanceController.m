//
//  GlanceController.m
//   WatchKit Extension
//
//  Created by Johannes Körner on 18.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "GlanceController.h"


@interface GlanceController()

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [WKInterfaceController openParentApplication:@{@"action" : @"showLocations"} reply:^(NSDictionary *replyInfo, NSError *error) {
        //Auf Karte anzeigen
        NSArray *dataLocations = [replyInfo valueForKey:@"locations"];
        [self.label setText:[NSString stringWithFormat:@"%ld", (long)dataLocations.count]];
    }];
    
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



