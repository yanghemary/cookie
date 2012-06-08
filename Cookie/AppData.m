//
//  AppData.m
//  Cookie
//
//  Created by He Yang on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppData.h"

@implementation AppData

@synthesize dishes = _dishes;
@synthesize dishID = _dishID;
@synthesize favorList = _favorList;

static AppData *instance = nil;

+ (AppData *)getAppDataInstance {
    if (instance == nil) {
        instance = [AppData new];
    }
    return instance;
}

- (AppData *)init {
    self = [super init];
    _dishID = 0;
    return self;
}

@end



