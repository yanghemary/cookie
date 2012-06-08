//
//  DishLandscapeVC.m
//  Cookie
//
//  Created by He Yang on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DishLandscapeVC.h"
#import "DishPortraitVC.h"
#import "DictDataConverter.h"

@interface DishLandscapeVC ()
@property (weak, nonatomic) IBOutlet UILabel *currentStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalStepsLabel;
@property (weak, nonatomic) IBOutlet UITextView *stepTextView;
@property (nonatomic) AppData *appdata;
@property (nonatomic) Dish *dish;

@end

@implementation DishLandscapeVC
@synthesize currentStepLabel;
@synthesize totalStepsLabel;
@synthesize stepTextView;
@synthesize appdata = _appdata;
@synthesize dish = _dish;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Swipe gesture
    UISwipeGestureRecognizer *rightSwipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [rightSwipeGR setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeGR];
    UISwipeGestureRecognizer *leftSwipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [rightSwipeGR setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipeGR];
	// Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _dish = [self.appdata.dishes objectAtIndex:self.appdata.dishID];
    [self loadStep];
    
}

- (void)loadStep {
    currentStepLabel.text = [NSString stringWithFormat:@"%i",_dish.currentStep.intValue];
    totalStepsLabel.text = [NSString stringWithFormat:@"/ %i",_dish.totalSteps.intValue];
    NSDictionary *stepDict = [DictDataConverter decodeDictionary:_dish.steps];
    
    stepTextView.text = [stepDict valueForKey:[NSString stringWithFormat:@"%i",_dish.currentStep.intValue]];
}
- (void)viewDidUnload
{
    [self setCurrentStepLabel:nil];
    [self setTotalStepsLabel:nil];
    [self setStepTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) swipeLeft:(UISwipeGestureRecognizer *)gesture {
    if (_dish.currentStep.intValue > 1) {
        _dish.currentStep = [NSNumber numberWithInt:_dish.currentStep.intValue - 1];
        [self loadStep];
    }
}

- (void) swipeRight:(UISwipeGestureRecognizer *)gesture {
    if (_dish.currentStep.intValue < _dish.totalSteps.intValue) {
        _dish.currentStep = [NSNumber numberWithInt:_dish.currentStep.intValue + 1];
        [self loadStep];
    }
}


- (AppData *)appdata {
    if (_appdata == nil) {
        _appdata = [AppData getAppDataInstance];
    }
    return _appdata;
}


@end
