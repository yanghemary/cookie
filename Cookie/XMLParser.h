//
//  XMLParser.h
//  Cookie
//
//  Created by He Yang on 6/1/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParserDelegate.h"
#import <CoreData/CoreData.h>

@interface XMLParser : NSXMLParser

+ (void)parse:(NSData *)data
    inContext:(NSManagedObjectContext *)context;

@end
