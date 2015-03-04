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
#define observe(who, sel, nam) [[NSNotificationCenter defaultCenter] addObserver:who selector:sel name:nam object:nil]
#define iPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface StoreHandler : NSObject

+ (id)shared;

@end
