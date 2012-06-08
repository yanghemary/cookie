//
//  DishPortraitVC.h
//  Cookie
//
//  Created by He Yang on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dish.h"
#import "AppData.h"


@interface DishPortraitVC : UIViewController {

}


@property (weak, nonatomic) Dish *dish;


- (void)setDish:(Dish *)dish;

@property (nonatomic) AppData *appdata;
@end
