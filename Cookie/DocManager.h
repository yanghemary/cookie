//
//  DocManager.h
//  Cookie
//
//  Created by He Yang on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^completion_block_t)(UIManagedDocument *document);

#define DEFAULT_FAVORLIST_NAME @"My Favorites"
#define DEFAULT_FAVORLIST_DICT @"favorlistDict.plist"



@interface DocManager : NSObject

//open or create the document as needed before executing a block using it
+ (void)useSharedManagedDocumentForDocumentNamed:(NSString *)documentName
                                  toExecuteBlock:(completion_block_t)completionBlock;

@end
