//
//  DishPortraitVC.m
//  Cookie
//
//  Created by He Yang on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DishPortraitVC.h"
#import "Cache.h"
#import "XMLParser.h"
#import <QuartzCore/QuartzCore.h>
#import "DocManager.h"
#import "DictDataConverter.h"
#import "DishLandscapeVC.h"
#import <MessageUI/MessageUI.h>

@interface DishPortraitVC () <UIScrollViewDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIPrintInteractionControllerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *intro;

@property (weak, nonatomic) IBOutlet UILabel *label_ingredients;
@property (weak, nonatomic) IBOutlet UILabel *label_procedure;

@property (weak, nonatomic) IBOutlet UIScrollView *portraitScrollView;
@property (nonatomic, strong) DishLandscapeVC *landscapeViewController;

@property (nonatomic) UIActionSheet *shareActionSheet;

@property (weak, nonatomic) IBOutlet UIImageView *printButton;
@property (weak, nonatomic) IBOutlet UIImageView *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic) CGFloat currentY;
@property (nonatomic) CGFloat defaultWidth;

@property (nonatomic, weak) NSNumber *initialState;
@property (nonatomic, strong) UIImage *imageFavored;
@property (nonatomic, strong) UIImage *imageNotFavored;
@end

@implementation DishPortraitVC 

@synthesize  shareActionSheet = _shareActionSheet;
@synthesize printButton;

@synthesize appdata = _appdata;
@synthesize imageFavored = _imageFavored;
@synthesize imageNotFavored = _imageNotFavored;
@synthesize imageScrollView;
@synthesize imageView;
@synthesize titleTextView;
@synthesize landscapeViewController = _landscapeViewController;
@synthesize shareButton;
@synthesize favoriteButton;


@synthesize intro;
@synthesize label_ingredients;
@synthesize label_procedure;
@synthesize portraitScrollView;
@synthesize mainView;
@synthesize dish = _dish;
@synthesize currentY = _currentY;
@synthesize defaultWidth = _defaultWidth;
@synthesize initialState = _initialState;

bool isShowingLandscapeView = false;


// image default width: 525, default height 394;
#define PHOTO_WIDTH 324
#define PHOTO_HEIGHT 243
#define DEFAULT_SPACE 20

- (UIImage *)imageFavored {
    if (_imageFavored == nil)
        _imageFavored = [UIImage imageNamed:@"heart.png"];
    return _imageFavored;
}

- (UIImage *)imageNotFavored {
    if (_imageNotFavored == nil)
        _imageNotFavored = [UIImage imageNamed:@"heart-gray.png"];
    return _imageNotFavored;
}

- (AppData *)appdata {
    if (_appdata == nil) {
        _appdata = [AppData getAppDataInstance];
    }
    return _appdata;
    
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)homePressed:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:YES];
}

/**************************************************************************
 Setup scroll view and image view when view loaded
 *************************************************************************/
- (void) viewDidLoad {
    [super viewDidLoad];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(orientationChanged:)
                   name:UIDeviceOrientationDidChangeNotification
                 object:nil];
    
    self.landscapeViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;    
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	self.landscapeViewController = [sb instantiateViewControllerWithIdentifier:@"SBLandscapeViewController"];
    
    
    self.imageScrollView.zoomScale = 1;
    [self.imageScrollView addSubview:self.imageView];
    self.imageScrollView.delegate = self;
    
    _defaultWidth = PHOTO_WIDTH - 2*DEFAULT_SPACE;
    
}



- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];    
    
    self.imageScrollView.frame = CGRectMake(0, 60, PHOTO_WIDTH, PHOTO_HEIGHT);
    [self updateCurrentY:imageScrollView];
    
    _dish = [self.appdata.dishes objectAtIndex:self.appdata.dishID];
    titleTextView.text = _dish.name;
    
    //Spinner starts
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    
    
    
    [self initShareButton];
    [self initFavouriteButton];
    [self initPrintButton];
    
    // Set up introduction label
    self.intro.frame = CGRectMake(DEFAULT_SPACE, _currentY-15, _defaultWidth, 100);
    self.intro.text = _dish.intro;
    [self updateCurrentY:intro];
        
    // Set up ingredients
    [self initIngredients];
    
    // Set up procedure
    [self initProcedure];
    
    // Set up background scroll view
    //CGFloat height = self.label_ingredients.frame.origin.y+self.ingredientsTableView.frame.size.height;
    
    
    self.portraitScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, _currentY);
    
    dispatch_queue_t loadQueue = dispatch_queue_create("Photo Load Queue", NULL);
    dispatch_async(loadQueue, ^{
        NSURL *url = [NSURL URLWithString:_dish.photoURL];
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
            [spinner stopAnimating];
            [spinner removeFromSuperview];

            self.imageView.image = image; 
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.layer.borderWidth = 3.f;
            imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            
            
            // [self.imageView addSubview:self.favoriteButton];
            //CALayer *imageViewLayer = imageScrollView.layer;
            //[imageViewLayer addSublayer:self.favoriteButton.layer];
            
            
            //self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            //self.imageView.frame = CGRectMake(0, 0, PHOTO_WIDTH, PHOTO_HEIGHT);
            
            //CGFloat zoomScale = PHOTO_WIDTH/image.size.width;
            // self.imageScrollView.contentSize = self.imageView.image.size;
            self.imageScrollView.contentSize = self.imageScrollView.frame.size;
            
            self.imageScrollView.minimumZoomScale = 0.5;
            self.imageScrollView.maximumZoomScale = 1.5;

            //self.imageScrollView.zoomScale = zoomScale;
            
        });
    });
    dispatch_release(loadQueue);
}

- (void)updateCurrentY:(UIView *)aView {
    _currentY = aView.frame.origin.y + aView.frame.size.height;
}

- (void)initShareButton {
    UITapGestureRecognizer *shareTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShare:)];

    [self.shareButton addGestureRecognizer:shareTapGR];
}

- (void)initFavouriteButton {
    _initialState = _dish.favored;
    UITapGestureRecognizer *favoriteTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFavorite:)];
    [self.favoriteButton addGestureRecognizer:favoriteTapGR];
    [self updateFavouriteButton];
}

- (void)initPrintButton {
    UITapGestureRecognizer *printTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapPrint:)];
    [self.printButton addGestureRecognizer:printTapGR];
}

- (void)tapShare: (UITapGestureRecognizer *)gesture {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Recipe" delegate:self  cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share via email",@"Share via SMS",nil];
    [actionSheet showInView:self.view];
    _shareActionSheet = actionSheet;
}

- (void)tapPrint: (UITapGestureRecognizer *)gesture {
    if ([UIPrintInteractionController isPrintingAvailable]) {
        UIPrintInteractionController *printer = [UIPrintInteractionController sharedPrintController];
        printer.delegate = self;
        printer.printInfo = [UIPrintInfo printInfo];
        printer.printInfo.outputType = UIPrintInfoOutputGeneral;
        printer.printInfo.jobName = @"Cookie dish";
        printer.printingItem = self.imageView.image;
        [printer presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
            if (!completed) {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == _shareActionSheet) {
        switch (buttonIndex) {
            case 0:
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *emailSender = [MFMailComposeViewController new];
                    emailSender.mailComposeDelegate = self;
                    
                    
                    [emailSender setSubject:@"Your friend just shared a recipe with you"];
                    
                    NSString *emailText = [@"Hi, your friend just shared a recipe with you. Check it out here: " stringByAppendingFormat:_dish.dishURL];
                    [emailSender setMessageBody:emailText isHTML:YES];
                    
                    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
                    
                    [emailSender addAttachmentData:imageData mimeType:@"image/png" fileName:_dish.name];
                    
                    [self presentModalViewController:emailSender animated:YES];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to sent email"
                                                                    message:@"Your device cannot send email for now. Please check."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                break;
            case 1:
                if ([MFMessageComposeViewController canSendText]) {
                    MFMessageComposeViewController *messageSender = [MFMessageComposeViewController new];
                    
                    NSString *messageText = [[NSString stringWithFormat:@"Hi, your friend just shared recipe of %@ with you. Check it out here: ",_dish.name] stringByAppendingFormat:_dish.dishURL];
                    
                    [messageSender setBody:messageText];
                    [self presentModalViewController:messageSender animated:YES];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to sent SMS"
                                                                    message:@"Your device cannot send SMS for now. Please check."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles: nil];
                    [alert show];
                }
                break;
            default:
                break;
        }
    }
}


- (void)tapFavorite: (UITapGestureRecognizer *)gesture {

    [DocManager useSharedManagedDocumentForDocumentNamed:@"Dishes" toExecuteBlock:^(UIManagedDocument *document) {
        if ([_dish.favored isEqualToNumber:[NSNumber numberWithInt:1]]) {
            _dish.favored = [NSNumber numberWithInt:0];
        } else {
            _dish.favored = [NSNumber numberWithInt:1];
        }
        [document.managedObjectContext save:nil];
    }];
    [self updateFavouriteButton];
}

- (void)updateFavouriteButton {
    
    if ([_dish.favored isEqualToNumber:[NSNumber numberWithInt:1]]) {
        [self.favoriteButton setImage:self.imageFavored];
    } else {
        [self.favoriteButton setImage:self.imageNotFavored];
    }
    
    /*
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Dish"];

    [DocManager useSharedManagedDocumentForDocumentNamed:DEFAULT_FAVORLIST_NAME toExecuteBlock:^(UIManagedDocument *favorList) {
        NSManagedObjectContext *context = favorList.managedObjectContext;
        NSArray *favoriteDishes = [context executeFetchRequest:request error:nil];
         
        if ([favoriteDishes count] > 0) {
            self.dishDoc = [favoriteDishes objectAtIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^ {
                
            });
        } else {
            self.dishDoc = nil;
            dispatch_async(dispatch_get_main_queue(), ^ {
                
            });
        }
    }];
     */
    
}

- (void)initIngredients {
    _currentY += 5;
    self.label_ingredients.frame = CGRectMake(DEFAULT_SPACE,  _currentY, _defaultWidth, 21);
    [self updateCurrentY:label_ingredients];
    
    
    NSDictionary *ingredientsDict = [DictDataConverter decodeDictionary:_dish.ingredients];
    
    for (NSString *ingredient in ingredientsDict.allKeys) {
        NSString *amount = [ingredientsDict valueForKey:ingredient];
        UITextView *amountTextView = [[UITextView alloc] init];
        
        amountTextView.frame = CGRectMake(DEFAULT_SPACE, _currentY, 65,28);
        amountTextView.text = amount;
        amountTextView.backgroundColor = [UIColor whiteColor];
        amountTextView.font = [UIFont fontWithName:@"Georgia" size:12.0];
        amountTextView.textColor = [UIColor grayColor];
        amountTextView.textAlignment = UITextAlignmentLeft;
        amountTextView.editable = NO;
    
        [self.portraitScrollView addSubview:amountTextView];
        
        UITextView *ingredientTextView = [[UITextView alloc] init];
        
        ingredientTextView.frame = CGRectMake(DEFAULT_SPACE + 65, _currentY, _defaultWidth - 65, 28);
        ingredientTextView.text = ingredient;
        ingredientTextView.backgroundColor = [UIColor whiteColor];
        ingredientTextView.font = [UIFont fontWithName:@"Arial" size:13.0];
        ingredientTextView.textColor = [UIColor blackColor];
        ingredientTextView.textAlignment = UITextAlignmentLeft;
        ingredientTextView.editable = NO;
        ingredientTextView.scrollEnabled = NO;
            
        [self.portraitScrollView addSubview:ingredientTextView];
        
        [self updateCurrentY:ingredientTextView];
        _currentY += 1;
        
    }

    _currentY += 10;

}

- (void)initProcedure {
    self.label_procedure.frame = CGRectMake(DEFAULT_SPACE,  _currentY, _defaultWidth, 21);
    [self updateCurrentY:label_procedure];
    
    
    
    NSDictionary *stepDict = [DictDataConverter decodeDictionary:_dish.steps];
    int numberOfSteps = [[stepDict allKeys] count];


    for (int i = 0; i < numberOfSteps; i++) {
        NSString *key = [NSString stringWithFormat:@"%i",i+1];  
        NSString *text = [stepDict valueForKey:key];
        UITextView *stepNumberTextView = [[UITextView alloc] init];
        
        stepNumberTextView.frame = CGRectMake(DEFAULT_SPACE + 10, _currentY, 28, 28);
        stepNumberTextView.text = key;
        stepNumberTextView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        stepNumberTextView.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        stepNumberTextView.textColor = [UIColor whiteColor];
        stepNumberTextView.textAlignment = UITextAlignmentCenter;
        stepNumberTextView.editable = NO;
        
       
        [self.portraitScrollView addSubview:stepNumberTextView];
        
        UITextView *stepDescriptionTextView = [[UITextView alloc] init];
        
        stepDescriptionTextView.frame = CGRectMake(DEFAULT_SPACE + 38, _currentY, _defaultWidth - 32, 40);
        stepDescriptionTextView.text = text;
        stepDescriptionTextView.backgroundColor = [UIColor whiteColor];
        stepDescriptionTextView.font = [UIFont fontWithName:@"Arial" size:13.0];
        stepDescriptionTextView.textColor = [UIColor blackColor];
        stepDescriptionTextView.textAlignment = UITextAlignmentLeft;
        stepDescriptionTextView.editable = NO;
        stepDescriptionTextView.scrollEnabled = NO;
                
        [self.portraitScrollView addSubview:stepDescriptionTextView];
        
         [self updateCurrentY:stepDescriptionTextView];
        _currentY += 5;
        
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(updateLandscapeView) withObject:nil afterDelay:0];
}

- (void)updateLandscapeView {

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView) {
        [self presentModalViewController:self.landscapeViewController animated:YES];
        isShowingLandscapeView = YES;
    } else if ((deviceOrientation == UIDeviceOrientationPortrait || deviceOrientation == UIDeviceOrientationPortraitUpsideDown) && isShowingLandscapeView) {
        [self dismissModalViewControllerAnimated:YES];
        isShowingLandscapeView = NO;
    }    
}

- (void)setTitle:(NSString *)title {
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 300, 40)];
    tlabel.text=title;
    //UIFont *myFont = [UIFont fontWithName:@"Arial Black" size:11];
    //tlabel.font = myFont;
    tlabel.textColor=[UIColor whiteColor];
    tlabel.backgroundColor =[UIColor clearColor];
    //tlabel.font = 
    [tlabel setShadowColor:[UIColor darkGrayColor]];
    [tlabel setShadowOffset:CGSizeMake(0, -0.5)];
    tlabel.adjustsFontSizeToFitWidth = YES;

    self.navigationItem.titleView = tlabel;
}


- (void)viewDidUnload {
    [self setPortraitScrollView:nil];
    [self setImageScrollView:nil];
    [self setImageView:nil];
    [self setIntro:nil];
    [self setLabel_ingredients:nil];
    [self setFavoriteButton:nil];
    [self setMainView:nil];
    [self setLabel_procedure:nil];
    
    [self setFavoriteButton:nil];
    [self setTitleTextView:nil];
    [self setShareButton:nil];
    [self setPrintButton:nil];
    [super viewDidUnload];
}
@end
