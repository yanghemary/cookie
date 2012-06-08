//
//  XMLParserDelegate.m
//  Cookie
//
//  Created by He Yang on 6/1/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "XMLParserDelegate.h"
#import "Dish.h"
#import "DictDataConverter.h"

@interface XMLParserDelegate()
@property (nonatomic, strong) NSManagedObjectContext *context;
//@property (nonatomic, strong) id currentObj;
@property (nonatomic, strong) Dish * dish;
@property (nonatomic, strong) NSString *currentElementValue;
@property (nonatomic, strong) DictDataConverter *converter;
@end

@implementation XMLParserDelegate
@synthesize dish = _dish;
@synthesize context = _context;
//@synthesize currentObj = _currentObj;
@synthesize currentElementValue = _currentElementValue;
@synthesize converter = _converter;

- (XMLParserDelegate *) initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    self.context = context;
    return self;
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict {
    //NSLog(@"%@",elementName);
    if ([elementName isEqualToString:@"dish"]) {
        _dish = [NSEntityDescription insertNewObjectForEntityForName:@"Dish" inManagedObjectContext:self.context];
        _dish.favored = [NSNumber numberWithInt:0];
        _dish.currentStep = [NSNumber numberWithInt:1];
        _dish.totalSteps = [NSNumber numberWithInt:0];
    } else {
        self.currentElementValue = elementName;
    }
}

- (void) parser:(NSXMLParser *)parser 
foundCharacters:(NSString *)string {
    //NSLog(@"%@",elementName);
    if ([_currentElementValue isEqualToString:@"name"]) {
         _dish.name = string;
    } else if ([_currentElementValue isEqualToString:@"dishID"]) {
        _dish.dishID = [NSNumber numberWithInt:string.integerValue];
    } else if ([_currentElementValue isEqualToString:@"intro"]) {
        _dish.intro = string;
    } else if ([_currentElementValue isEqualToString:@"category"]) {
        _dish.category = string;
    } else if ([_currentElementValue isEqualToString:@"dishURL"]) {
        _dish.dishURL = string;
    } else if ([_currentElementValue isEqualToString:@"photoURL"]) {
        _dish.photoURL = string;
    } else if ([_currentElementValue isEqualToString:@"procedure"]) {
        NSArray *stepArray = [string componentsSeparatedByString:@";"];
        NSMutableDictionary *stepDict = [[NSMutableDictionary alloc] initWithDictionary:nil];
        int counter = 0;
        
        for (NSString *step in stepArray) {
            counter++;
            [stepDict setValue:step forKey:[NSString stringWithFormat:@"%i",counter]];
        }
                
        _dish.steps = [DictDataConverter encodeDictionary:stepDict];
        _dish.totalSteps = [NSNumber numberWithInt:[stepArray count]];
    } else if ([_currentElementValue isEqualToString:@"ingredients"]) {
        NSArray *ingredientsArray = [string componentsSeparatedByString:@";"];
        NSMutableDictionary *ingredientsDict = [[NSMutableDictionary alloc] initWithDictionary:nil];
        
        for (NSString *ingredientSet in ingredientsArray) {
            NSArray *ingredientArray = [ingredientSet componentsSeparatedByString:@","];
            NSString *amount;
            NSString *ingredient;
            if ([ingredientArray count]>1) {
                amount = [ingredientArray objectAtIndex:0];
                ingredient = [ingredientArray objectAtIndex:1];
            } else if ([ingredientArray count]>0) {
                amount = @"";
                ingredient = [ingredientArray objectAtIndex:0];
            }
            
            [ingredientsDict setValue:amount forKey:ingredient];
            
        }
        
        _dish.ingredients = [DictDataConverter encodeDictionary:[ingredientsDict copy]] ;
    }
        
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"dish"]) {
        _dish = nil;
    } else {
        self.currentElementValue = nil;
    }
}





@end
