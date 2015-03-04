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
    self.timeStamp = [NSDate date];
    
    [self observeTitle];
}

- (void)observeTitle {
    [self addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:keyPath]) {
        NSString *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSString *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (![newValue isEqualToString:oldValue]) {
            self.firstLetter = [newValue substringToIndex:1];
        }
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
    [self setValue:[self calcHash] forKey:@"myHash"];
}

- (NSString *)calcHash {
    NSArray *array = [[self.notes allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]]];
    
    if (array.count > 0) {
        return [NSString stringWithFormat:@"%@%ld%@", self.title, (long)array.count, [(Note *)[array firstObject] calcHash]];
    }
    else {
        return [NSString stringWithFormat:@"%@%ld%@", self.title, (long)array.count, @"---"];
    }
}

@dynamic timeStamp;
@dynamic title;
@dynamic notes;
@dynamic myHash;
@dynamic firstLetter;

@end
