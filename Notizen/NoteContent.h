//
//  NoteContent.h
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface NoteContent : NSManagedObject

- (NSString *)calcHash;

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * dataType;
@property (nonatomic, retain) NSString * myHash;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) Note *note;

@end
