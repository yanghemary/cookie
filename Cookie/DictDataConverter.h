//
//  DictDataConverter.h
//  Cookie
//
//  Created by He Yang on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictDataConverter : NSObject

+ (NSData *)encodeDictionary:(NSDictionary *)dict;
+ (NSDictionary *)decodeDictionary:(NSData *)data;

@end
