//
//  XMLParserDelegate.h
//  Cookie
//
//  Created by He Yang on 6/1/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLParserDelegate.h"

@interface XMLParserDelegate : NSObject <NSXMLParserDelegate>

- (XMLParserDelegate *) initWithContext:(NSManagedObjectContext *)context;

@end
