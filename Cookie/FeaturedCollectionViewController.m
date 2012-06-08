//
//  FeaturedCollectionViewController.m
//  Cookie
//
//  Created by He Yang on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedCollectionViewController.h"
#import "AppData.h"
#import "Dish.h"
#import "Cache.h"
#import <QuartzCore/QuartzCore.h>
#import "DishPortraitVC.h"

@interface FeaturedCollectionViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) AppData *appdata;
@property (nonatomic) NSMutableArray *imageViews;
@property (nonatomic) NSMutableDictionary *loadedPhotos;
@property (nonatomic) DishPortraitVC *dishPortraitVC;

@end

@implementation FeaturedCollectionViewController
@synthesize imageViews = _imageViews;
@synthesize scrollView;
@synthesize appdata = _appdata;
@synthesize loadedPhotos = _loadedPhotos;
@synthesize dishPortraitVC = _dishPortraitVC;

#define THUMB_WIDTH 154
#define THUMB_HEIGHT 115.6
#define LINE_SPACE   4
#define LEFT_COLUMN_X   4
#define RIGHT_COLUMN_X  162
#define FIRST_COLUMN_X  4
#define SECOND_COLUMN_X 163
#define THIRD_COLUMN_X  322


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImageView *imageView = [UIImageView new];
    [self.imageViews addObject:imageView];
    
    //FeaturedCollectionViewController *myViewController = [[FeaturedCollectionViewController alloc] init];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	self.dishPortraitVC = [sb instantiateViewControllerWithIdentifier:@"detailPageNavigationController"];

    //self.dishPortraitVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
}

// Draw thumbnails

- (void)drawThumbForDish:(Dish *)dish atX:(CGFloat)x atY:(CGFloat)y {
    UIImageView *imageView = [UIImageView new];
    [self.imageViews addObject:imageView];
    
    UIImage *image = [_loadedPhotos objectForKey:dish.dishID];
    
    if (image == nil) {
        imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        dispatch_queue_t loadQueue = dispatch_queue_create("Collection View Photo Load Queue", NULL);
        dispatch_async(loadQueue, ^{
            NSURL *url = [NSURL URLWithString:dish.photoURL];
            NSData *data;
            if ([Cache isURLCached:url]) {
                data = [Cache getCachedData:url];
            } else {
                data = [[NSData alloc] initWithContentsOfURL:url];
                MANUAL_LATENCY
                [Cache addDataToCache:url withData:data];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [_loadedPhotos setObject:image forKey:dish.dishID];
                
                UIImage *image = [UIImage imageWithData:data];
                imageView.image = image;
                // [self.tableView reloadData]; 
            });
        });
        
        dispatch_release(loadQueue);
    } else {
        imageView.image = image;
    }
    
    
    imageView.frame = CGRectMake(x, y, THUMB_WIDTH, THUMB_HEIGHT);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.shadowRadius = 2.f;
    imageView.layer.shadowOpacity = .85f;
    imageView.layer.shadowOffset = CGSizeMake(1.f, 1.f);
    imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    imageView.layer.shouldRasterize = YES;
    imageView.layer.masksToBounds = NO;
    // imageView.layer.cornerRadius = 15.f;
    // imageView.transform = CGAffineTransformMakeRotation(0.03f);
    imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapThumb:)];
    [imageView addGestureRecognizer:tapGR];
    [self.scrollView addSubview:imageView];
}

- (void)clearThumbs {
    for (UIImageView *imageView in self.imageViews) {
        [imageView removeFromSuperview];
    }
    [self.imageViews removeAllObjects];
}

- (void)drawThumbs {
    [self clearThumbs];
    int dishCount = [self.appdata.dishes count];
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation)) {
        int lineCount = (int)floor((double)dishCount / 2.0);
        int index = 0;
        Dish *dish;
        for (int i = 0; i < lineCount; i ++) {
            if (index == dishCount) {
                break;
            }
            dish = [self.appdata.dishes objectAtIndex:index];
            [self drawThumbForDish:dish atX:LEFT_COLUMN_X atY:i*(LINE_SPACE + THUMB_HEIGHT) + LINE_SPACE];
            index ++;
            if (index == dishCount) {
                break;
            }
            dish = [self.appdata.dishes objectAtIndex:index];
            [self drawThumbForDish:dish atX:RIGHT_COLUMN_X atY:i*(LINE_SPACE + THUMB_HEIGHT) + LINE_SPACE];
            index ++;
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, lineCount * (LINE_SPACE + THUMB_HEIGHT) + LINE_SPACE);
    } else {
        int lineCount = (int)ceil((double)dishCount / 3.0);
        int index = 0;
        Dish *dish;
        for (int i = 0; i < lineCount; i ++) {
            if (index == dishCount) {
                break;
            }
            dish = [self.appdata.dishes objectAtIndex:index];
            [self drawThumbForDish:dish atX:FIRST_COLUMN_X atY:i*(LINE_SPACE + THUMB_HEIGHT) + LINE_SPACE];
            index ++;
            if (index == dishCount) {
                break;
            }
            dish = [self.appdata.dishes objectAtIndex:index];
            [self drawThumbForDish:dish atX:SECOND_COLUMN_X atY:i*(LINE_SPACE + THUMB_HEIGHT) + LINE_SPACE];
            index ++;
            if (index == dishCount) {
                break;
            }
            dish = [self.appdata.dishes objectAtIndex:index];
            [self drawThumbForDish:dish atX:THIRD_COLUMN_X atY:i*(LINE_SPACE + THUMB_HEIGHT) + LINE_SPACE];
            index ++;
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, lineCount * (LINE_SPACE + THUMB_HEIGHT) + LINE_SPACE);
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CollectionViewIsShown"
                                                        object:self];
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    [self drawThumbs];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CollectionViewIsUnshown"
                                                        object:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    if (UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    [self drawThumbs];
}

- (void)tapThumb:(UITapGestureRecognizer *)gesture {
    int index = [self.imageViews indexOfObject:gesture.view];
    self.appdata.dishID = index;
    
    //FeaturedCollectionViewController *myViewController = [[FeaturedCollectionViewController alloc] init];
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
    //now present this navigation controller as modally 
    //[self presentModalViewController:navigationController YES];
    //[self presentModalViewController:self.dishPortraitVC animated:YES];
    [self presentViewController:self.dishPortraitVC animated:YES completion:^{}];
}


- (NSMutableArray *)imageViews {
    if (_imageViews == nil) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (NSDictionary *)loadedPhotos {
    if (_loadedPhotos == nil) {
        _loadedPhotos = [NSMutableDictionary new];
    }
    
    return _loadedPhotos;
}

- (AppData *)appdata {
    if (_appdata == nil) {
        _appdata = [AppData getAppDataInstance];
    }
    return _appdata;
}


@end
