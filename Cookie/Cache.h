//
//  Cache.h
//  Cookie
//
//  Created by He Yang on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_RECENT_VIEW_LIST_FILE @"recentlist.plist"
#define DEFAULT_CACHE_DICT_FILE @"cachedict.plist"
#define CACHE_LIMIT 1024*1024*10

#define ENABLE_MANUAL_LATENCY 1
#if ENABLE_MANUAL_LATENCY
#define MANUAL_LATENCY [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
#else
#define MANUAL_LATENCY
#endif

@interface Cache: NSObject

+ (void) init;
+ (BOOL) isURLCached:(NSURL*)url;
+ (NSData*) getCachedData:(NSURL*)url;
+ (BOOL) addDataToCache:(NSURL*)url withData:(NSData*)data;
+ (BOOL) removeDataFromCache:(NSURL *)url;

@end

