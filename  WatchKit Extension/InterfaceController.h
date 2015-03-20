//
//  InterfaceController.h
//   WatchKit Extension
//
//  Created by Johannes Körner on 18.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController {
    NSDate *timeStamp;
    BOOL addToLast;
}

- (IBAction)markLocation:(id)sender;
- (IBAction)writeNote:(id)sender;

@property (strong) IBOutlet WKInterfaceButton *markLocationButton;
@property (strong) IBOutlet WKInterfaceButton *writeNoteButton;
@property (strong) IBOutlet WKInterfaceSeparator *separator;

@end
