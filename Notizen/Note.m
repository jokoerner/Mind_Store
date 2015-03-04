//
//  Note.m
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "Note.h"
#import "NoteContainer.h"
#import "NoteContent.h"


@implementation Note

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
    NSArray *array = [[self.noteContents allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    
    NSString *add = @"";
    for (NoteContent *content in array) {
        add = [NSString stringWithFormat:@"%@%@", add, [content hash]];
    }
    
    return [NSString stringWithFormat:@"%@%ld%@", self.noteContainer.title, (long)array.count, add];
}

@dynamic creation;
@dynamic timeStamp;
@dynamic noteContainer;
@dynamic noteContents;
@dynamic myHash;

@end
