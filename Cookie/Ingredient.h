//
//  Ingredient.h
//  Cookie
//
//  Created by He Yang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Dish;

@interface Ingredient : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfDishes;
@property (nonatomic, retain) NSSet *dishes;
@end

@interface Ingredient (CoreDataGeneratedAccessors)

- (void)addDishesObject:(Dish *)value;
- (void)removeDishesObject:(Dish *)value;
- (void)addDishes:(NSSet *)values;
- (void)removeDishes:(NSSet *)values;

@end
