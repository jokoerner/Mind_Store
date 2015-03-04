//
//  NoteContent.m
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "NoteContent.h"
#import "Note.h"


@implementation NoteContent


- (void)awakeFromInsert {
    [self updateHash];
}

- (void)willSave {
    [self updateHash];
}

- (void)updateHash {
    self.myHash = [self hash];
}

- (NSString *)hash {
    return [NSString stringWithFormat:@"%@%lu", self.dataType, (unsigned long)self.data.length];
}

@dynamic data;
@dynamic dataType;
@dynamic index;
@dynamic timeStamp;
@dynamic note;
@dynamic myHash;

@end
