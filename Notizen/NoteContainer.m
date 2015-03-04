//
//  NoteContainer.m
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "NoteContainer.h"
#import "Note.h"


@implementation NoteContainer

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
    NSArray *array = [[self.notes allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]]];
    
    if (array.count > 0) {
        return [NSString stringWithFormat:@"%@%ld%@", self.title, (long)array.count, [(Note *)[array firstObject] hash]];
    }
    else {
        return [NSString stringWithFormat:@"%@%ld%@", self.title, (long)array.count, @"---"];
    }
}

@dynamic timeStamp;
@dynamic title;
@dynamic notes;
@dynamic myHash;

@end
