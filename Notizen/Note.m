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
    NSDate *date = [NSDate date];
    self.creation = date;
    self.timeStamp = date;
}

- (void)prepareForDeletionOfNoteContentObject:(NoteContent *)noteContent {
    NSArray *array = [[self.noteContents allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    NSInteger index = [array indexOfObject:noteContent];
    
    for (NSInteger i = index+1; i < array.count; i++) {
        NoteContent *aContentObject = [array objectAtIndex:i];
        [aContentObject setIndex:@(i-1)];
    }
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
    NSArray *array = [[self.noteContents allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    
    NSString *add = @"";
    for (NoteContent *content in array) {
        add = [NSString stringWithFormat:@"%@%@", add, [content calcHash]];
    }
    
    return [NSString stringWithFormat:@"%@%ld%@", self.noteContainer.title, (long)array.count, add];
}

- (Note *)exactCopy {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    Note *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
    [newManagedObject setCreation:self.creation];
    return newManagedObject;
}

@dynamic creation;
@dynamic timeStamp;
@dynamic noteContainer;
@dynamic noteContents;
@dynamic myHash;

@end
