//
//  XMLParser.m
//  Cookie
//
//  Created by He Yang on 6/1/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "XMLParser.h"


@implementation XMLParser

+ (void)removeContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Dish"];
    NSArray *results = [context executeFetchRequest:request error:nil];
    for (NSManagedObject *obj in results) {
        [context deleteObject:obj];
    }
}

+ (void)parse:(NSData *)data
    inContext:(NSManagedObjectContext *)context {
    
    [XMLParser removeContext:context];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    XMLParserDelegate *delegate = [[XMLParserDelegate alloc] initWithContext:context];
    [parser setDelegate:delegate];
    BOOL success = [parser parse];
    if (success) {
        //NSLog(@"Succeeded in parsing the XML");
    }
    else {
        NSLog(@"Failed in parsing the XML");
    }
}


@end
