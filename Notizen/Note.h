//
//  Note.h
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NoteContainer, NoteContent;

@interface Note : NSManagedObject

- (NSString *)calcHash;

@property (nonatomic, retain) NSDate * creation;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * myHash;
@property (nonatomic, retain) NoteContainer *noteContainer;
@property (nonatomic, retain) NSSet *noteContents;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addNoteContentsObject:(NSManagedObject *)value;
- (void)removeNoteContentsObject:(NSManagedObject *)value;
- (void)addNoteContents:(NSSet *)values;
- (void)removeNoteContents:(NSSet *)values;

- (Note *)exactCopy;
- (void)prepareForDeletionOfNoteContentObject:(NoteContent *)noteContent;

@end
