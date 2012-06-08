//
//  FavouritesTVC.m
//  Cookie
//
//  Created by He Yang on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesTVC.h"
#import "DocManager.h"
#import "XMLParser.h"
#import "Dish.h"
#import "AppData.h"
#import "Cache.h"
#import "FeaturedCollectionViewController.h"
#import "DishPortraitVC.h"

@interface FavouritesTVC ()
//@property (nonatomic, strong) FeaturedCollectionVC *collectionViewController;
@property (nonatomic) AppData *appdata;
@property (nonatomic) NSMutableDictionary *loadedImages;
@property (nonatomic, strong) NSMutableArray *favorList;

@end

@implementation FavouritesTVC 

//@synthesize collectionViewController;
@synthesize appdata = _appdata;
@synthesize loadedImages = _loadedImages;
@synthesize favorList = _favorList;


// image default width: 525, default height 394;
#define THUMB_WIDTH 133.2
#define THUMB_HEIGHT 100

- (NSDictionary *)loadedImages {
    if (_loadedImages == nil) {
        _loadedImages = [NSMutableDictionary new];
    }
    
    return _loadedImages;
}

- (void)loadFavourites {
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _favorList = [[NSMutableArray alloc] init];
            
    for (Dish *dish in self.appdata.dishes) {
        
        if ([dish.favored isEqualToNumber:[NSNumber numberWithInt:1]]) {
            [_favorList insertObject:dish atIndex:0];
            //[_favorList arrayByAddingObject:dish];
            NSLog(@"%@",dish.name);
        }
    }
    
    [self.tableView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_favorList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"dishCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Dish *dish = [_favorList objectAtIndex:indexPath.row];
       
    cell.imageView.bounds = CGRectMake(0, 0, 130, 100);
    
    cell.textLabel.text = dish.name;
    
    cell.detailTextLabel.text = dish.intro;
    cell.imageView.frame = CGRectMake(0, 0, THUMB_WIDTH, THUMB_HEIGHT);
    
    UIImage *image = [_loadedImages objectForKey:indexPath];
    
    
    if (image == nil) {
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        
        dispatch_queue_t loadQueue = dispatch_queue_create("FavorList Thumbnail Load Queue", NULL);
        
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
                [_loadedImages setObject:image forKey:indexPath];
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
        Dish *dish = [_favorList objectAtIndex:indexPath.row];
        self.appdata.dishID = dish.dishID.intValue;
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
