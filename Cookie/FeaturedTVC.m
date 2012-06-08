//
//  FeaturedTVC.m
//  Cookie
//
//  Created by He Yang on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedTVC.h"
#import "DocManager.h"
#import "XMLParser.h"
#import "Dish.h"
#import "AppData.h"
#import "Cache.h"
#import "FeaturedCollectionViewController.h"
#import "DishPortraitVC.h"
#import <QuartzCore/QuartzCore.h>

@interface FeaturedTVC ()
//@property (nonatomic, strong) FeaturedCollectionVC *collectionViewController;
@property (nonatomic) AppData *appdata;
@property (nonatomic) NSMutableDictionary *loadedPhotos;

@end

@implementation FeaturedTVC 

//@synthesize collectionViewController;
@synthesize appdata = _appdata;
@synthesize loadedPhotos = _loadedPhotos;

// image default width: 525, default height 394;
#define THUMB_WIDTH 133.2
#define THUMB_HEIGHT 100

- (NSDictionary *)loadedPhotos {
    if (_loadedPhotos == nil) {
        _loadedPhotos = [NSMutableDictionary new];
    }
    
    return _loadedPhotos;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    spinner.transform = transform;
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    
    NSString *appDir = [[NSBundle mainBundle] resourcePath];
    NSString *xmlPath = [appDir stringByAppendingString:@"/cookie.xml"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:xmlPath];
    [DocManager useSharedManagedDocumentForDocumentNamed:@"Dishes" 
                                          toExecuteBlock:^(UIManagedDocument *document) {
                                              [XMLParser parse:data inContext:document.managedObjectContext];
                                              NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Dish"];
                                              NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dishID" ascending:YES];
                                              request.sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
                                              self.appdata.dishes = [document.managedObjectContext executeFetchRequest:request error:nil];
                                              //Dish *dish = [self.appdata.dishes objectAtIndex:0];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [spinner stopAnimating];
                                                  [spinner removeFromSuperview];
                                                  [self.tableView reloadData];
                                              });
                                          }];
    /*
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    self.collectionViewController = [storyBoard instantiateViewControllerWithIdentifier:@"StoryBoardCollectionVC"];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.collectionViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
     */
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"%i",[self.appdata.dishes count]);
    return [self.appdata.dishes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"dishCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Dish *dish = [self.appdata.dishes objectAtIndex:indexPath.row];
    cell.imageView.bounds = CGRectMake(0, 0, 130, 100);
    
    cell.textLabel.text = dish.name;
    cell.detailTextLabel.text = dish.intro;
    cell.imageView.frame = CGRectMake(0, 0, THUMB_WIDTH, THUMB_HEIGHT);
    
    
    /*
    dispatch_async(loadQueue, ^{
        NSURL *url = [NSURL URLWithString:dish.photoURL];
        UIImage *image;
        if ([Cache isURLCached:url]) {
            image = [UIImage imageWithData:[Cache getCachedData:url]];
        } else {
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
            MANUAL_LATENCY
            image = [UIImage imageWithData:imageData];
            [Cache addDataToCache:url withData:imageData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            cell.imageView.image = image; 
            // [self.tableView reloadData];
        });
    });
    */
    
    UIImage *image = [_loadedPhotos objectForKey:indexPath];
    
    
    if (image == nil) {
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        
    
        cell.imageView.layer.borderWidth = 3.f;
        cell.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        //cell.imageView.bounds = CGRectMake(0, 0, THUMB_WIDTH, THUMB_HEIGHT);
        
        dispatch_queue_t loadQueue = dispatch_queue_create("Thumbnail Load Queue", NULL);
        
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
                [_loadedPhotos setObject:image forKey:indexPath];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                UIImage *image = [UIImage imageWithData:data];
                cell.imageView.image = image; 
                // [self.tableView reloadData]; 
            });
        });
        dispatch_release(loadQueue);
    } else {
        cell.imageView.image = image;
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDish"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        self.appdata.dishID = indexPath.row;
    } 
}



- (AppData *)appdata {
    if (_appdata == nil) {
        _appdata = [AppData getAppDataInstance];
    }
    return _appdata;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


@end
