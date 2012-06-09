//
//  Dish.h
//  Cookie
//
//  Created by He Yang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ingredient;

@interface Dish : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * currentStep;
@property (nonatomic, retain) NSNumber * dishID;
@property (nonatomic, retain) NSString * dishURL;
@property (nonatomic, retain) NSNumber * favored;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSData * steps;
@property (nonatomic, retain) NSNumber * totalSteps;
@property (nonatomic, retain) NSString * myReview;
@property (nonatomic, retain) NSData * ingredients;
@property (nonatomic, retain) NSSet *myIngredients;
@end

@interface Dish (CoreDataGeneratedAccessors)

- (void)addMyIngredientsObject:(Ingredient *)value;
- (void)removeMyIngredientsObject:(Ingredient *)value;
- (void)addMyIngredients:(NSSet *)values;
- (void)removeMyIngredients:(NSSet *)values;

@end
