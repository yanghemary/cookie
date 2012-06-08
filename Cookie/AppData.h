//
//  AppData.h
//  Cookie
//
//  Created by He Yang on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppData : NSObject

+ (AppData *)getAppDataInstance;
@property (nonatomic) NSArray *dishes;
@property (nonatomic) NSArray *favorList;
@property (nonatomic) int dishID;

@end
