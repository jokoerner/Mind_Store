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
    self.index = @-1;
    self.timeStamp = [NSDate date];
}

- (void)prepareForDeletion {
    if (self.note) [self.note prepareForDeletionOfNoteContentObject:self];
}

- (void)willSave {
    [super willSave];
    NSString *newHash = [self calcHash];
    if (![newHash isEqualToString:self.myHash]) {
        self.myHash = newHash;
    }
    NSDate *currentDate = [NSDate date];
    if ([currentDate timeIntervalSinceDate:self.timeStamp] > 1.0) {
        self.timeStamp = currentDate;
    }
}

- (void)updateHash {
    self.myHash = [self calcHash];
}

- (NSString *)calcHash {
    return [NSString stringWithFormat:@"%@%lu", self.dataType, (unsigned long)self.data.length];
}

@dynamic data;
@dynamic dataType;
@dynamic index;
@dynamic timeStamp;
@dynamic note;
@dynamic myHash;

@end
