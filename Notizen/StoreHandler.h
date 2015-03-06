//
//  StoreHandler.h
//  Notizen
//
//  Created by Johannes Körner on 03.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define post(name) [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil]
#define postWithObject(name, anObject) [[NSNotificationCenter defaultCenter] postNotificationName:name object:anObject]
#define observe(who, sel, nam) [[NSNotificationCenter defaultCenter] addObserver:who selector:sel name:nam object:nil]
#define removeObserver(who) [[NSNotificationCenter defaultCenter] removeObserver:who]

#define iPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define iPhone ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)

#define backgroundColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]]

#define getDefault(key) [[NSUserDefaults standardUserDefaults] valueForKey:key]
#define setDefault(value, key) [[NSUserDefaults standardUserDefaults] setValue:value forKey:key]

@interface StoreHandler : NSObject

+ (id)shared;

@end
