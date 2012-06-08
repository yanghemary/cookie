//
//  Dish.h
//  Cookie
//
//  Created by He Yang on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Dish : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * dishID;
@property (nonatomic, retain) NSString * dishURL;
@property (nonatomic, retain) NSNumber * favored;
@property (nonatomic, retain) NSData * ingredients;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSData * steps;
@property (nonatomic, retain) NSNumber * currentStep;
@property (nonatomic, retain) NSNumber * totalSteps;

@end
