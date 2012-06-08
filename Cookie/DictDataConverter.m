//
//  DictDataConverter.m
//  Cookie
//
//  Created by He Yang on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DictDataConverter.h"

@implementation DictDataConverter

/**************************************************************************
 As NSDictionary data cannot be saved in core data,
 we need two helpers here to help with format changing
 *************************************************************************/

+ (NSData *)encodeDictionary:(NSDictionary *)dict {
    NSMutableData *data = [NSMutableData new];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dict];
    [archiver finishEncoding];
    return data;
}

+ (NSDictionary *)decodeDictionary:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    return dict;
}


@end
