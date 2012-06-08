//
//  Cache.m
//  Cookie
//
//  Created by He Yang on 6/2/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "Cache.h"

@interface Cache ()
#define CACHE_LIMIT 1024*1024*10
@end

@implementation Cache

static bool cacheInitialized = false;
static int cacheSize;
static int usedCacheSize;

static NSString* documentDir;

static NSMutableDictionary* cacheDict;
static NSString* cacheDictPath;

static NSMutableArray* recentViewList;
static NSString* recentViewListPath;
/*****************************************************************

*****************************************************************/


+ (void)init {
    cacheInitialized = YES;
    cacheSize = CACHE_LIMIT;
    usedCacheSize = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    documentDir = [paths objectAtIndex:0];    
    // set cache dictionary path as current document directory with appending cache naming component
    cacheDictPath = [[documentDir init] stringByAppendingPathComponent:DEFAULT_CACHE_DICT_FILE];
    cacheDict = [[NSMutableDictionary alloc] initWithContentsOfFile:cacheDictPath];
    if (cacheDict == nil) {
        cacheDict = [[NSMutableDictionary alloc] init];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:cacheDictPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    for (id key in cacheDict) {
        NSString* path = [cacheDict objectForKey:key];
        UInt32 fileSize = [[fileManager attributesOfItemAtPath:path error:NULL] fileSize];
        usedCacheSize += fileSize;
    }
    
    // initialize recent viewing list
    recentViewListPath = [documentDir stringByAppendingPathComponent:DEFAULT_RECENT_VIEW_LIST_FILE];
    recentViewList = [[NSMutableArray alloc] initWithContentsOfFile:recentViewListPath];
    if (recentViewList == nil) {
        recentViewList = [[NSMutableArray alloc] init];
    }

    
}

+ (NSString*) generateKeyFromURL:(NSURL*)url {
    NSString* key = [url relativePath];
    return [key stringByReplacingOccurrencesOfString:@"/" withString:@"."];
}

+ (BOOL) addDataToCache:(NSURL*)url withData:(NSData*)data
{
    if (!cacheInitialized) {
        [Cache init];
    }
    BOOL result = NO;
    NSString *key = [Cache generateKeyFromURL:url];
    if (key) {
        NSString *path = [documentDir stringByAppendingPathComponent:key];
        result = [data writeToFile:path atomically:YES];
        if (result) {
            @synchronized(self) {
                usedCacheSize += [data length];
                [cacheDict setValue:path forKey:key];
                                
                while (usedCacheSize > cacheSize) {
                    NSString* key = [recentViewList objectAtIndex:0];
                    if (key != nil) {
                        [self removeCachedDataWithKey:key];
                    }
                    //NSLog(@"%@", recentViewList);
                    //NSLog(@"usedCacheSize = %d/%d\n", usedCacheSize, cacheSize);
                }
                
                [cacheDict writeToFile:cacheDictPath atomically:YES];
                [recentViewList writeToFile:recentViewListPath atomically:YES];
            }
        }
    }
    return result;
}

+ (BOOL) isURLCached:(NSURL *)url {
    if (!cacheInitialized) {
        [Cache init];
    }
    NSString* path = [cacheDict valueForKey:[Cache generateKeyFromURL:url]];
    return (path != nil);
}

+ (NSData*) getCachedData:(NSURL *)url {
    if (!cacheInitialized) {
        [Cache init];
    }
    NSString* key = [Cache generateKeyFromURL:url];
    NSString* path = [cacheDict valueForKey:key];
    if (path == nil) {
        return nil;
    }
    else {
        @synchronized(self) {
            int index = -1;
            for (int i = 0; i < [recentViewList count]; i++) {
                if ([[recentViewList objectAtIndex:i] isEqualToString:key]) {
                    index = i;
                    break;
                }
            }
            if (index >= 0) {
                [recentViewList removeObjectAtIndex:index];
            }
            [recentViewList addObject:key];
            //NSLog(@"%@", recentViewList);
            //NSLog(@"usedCacheSize = %d/%d\n", usedCacheSize, cacheSize);
            return ([NSData dataWithContentsOfFile:path]);
        }
    }
}

+ (BOOL) removeCachedDataWithKey:(NSString *)key {
    if (!cacheInitialized) {
        [Cache init];
    }
    BOOL result = NO;
    NSString* path = [cacheDict valueForKey:key];
    if (path != nil) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        @synchronized(self) {
            NSError *error;
            BOOL fileExists = [fileManager fileExistsAtPath:path];
            if (fileExists) {
                usedCacheSize -= [[fileManager attributesOfItemAtPath:path error:NULL] fileSize];
                result = [fileManager removeItemAtPath:path error:&error];
                if (result == NO) {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
                else {
                    NSLog(@"Cache: removed %s", [key UTF8String]);
                }
            }
            [cacheDict removeObjectForKey:key];
            int index = -1;
            for (int i = 0; i < [recentViewList count]; i++) {
                if ([[recentViewList objectAtIndex:i] isEqualToString:key]) {
                    index = i;
                    break;
                }
            }
            if (index >= 0) {
                [recentViewList removeObjectAtIndex:index];
            }
        }
    }
    return result;
}

+ (BOOL) removeDataFromCache:(NSURL *)url {
    NSString* key = [Cache generateKeyFromURL:url];
    return [self removeCachedDataWithKey:key];
}

@end

 

