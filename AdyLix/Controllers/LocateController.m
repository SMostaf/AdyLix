//
//  LocateController.m
//  Ady
//
//  LocateController controller for the discover scene
//  shows styles and individual items on image list view
//  swipe action left/right to view different styles
//  swipe action up/down to view indiviual items per selected style
//  like whole style will automatically like all associated items
//
//  Created by Sahar Mostafa on 10/15/15.
//  Copyright © 2015 Sahar Mostafa. All rights reserved.
//
#import <Addressbook/ABPerson.h>
#import "LocateController.h"
#import "Parse/Parse.h"
#import "ParseUI/PFImageView.h"
#import "User.h"
#import "Style.h"
#import "ShareHelper.h"
#import "UserController.h"
#import "Utility.h"
#import "FBLoginViewController.h"

#define MERCHANTID @"merchant.com.adylix"
#define DESC_CUSTOM_TAG 1445


@interface LocateController ()


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIImageView *imgMoreBorder;
@property (weak, nonatomic) IBOutlet UILabel *lblItemsCount;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblStyleName;

@property (weak, nonatomic) IBOutlet UILabel *lblLikes;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@property (weak, nonatomic) IBOutlet UIButton *btnLike;

@property (weak, nonatomic) IBOutlet UIButton *btnCurrStyle;
@property (weak, nonatomic) IBOutlet UIImageView *styleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property  (nonatomic, strong) CLLocationManager* locationManager;
//@property (nonatomic, copy) NSArray* itemsArr;
@property UIImageView *activityImageView;
@property BOOL alertShown;
@property (strong, nonatomic) NSArray *stylesArr;
@property NSInteger currentStyleIndex;
@property StyleDetail* currStyleDetail;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property BOOL loaded;
@end

@implementation LocateController

- (IBAction)navProfile:(id)sender {
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = false;

     if (!self.loaded) {
       //  [self.navigationController setNavigationBarHidden:NO animated:NO];
         self.navigationItem.leftBarButtonItems = [Utility getNavOtherMenu:self];

         self.loaded = YES;
    }

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    self.navigationController.navigationBar.hidden = false;

    [self.activityView startAnimating];
  
    
    self.stylesArr = [[NSArray alloc]init];
    
    [_styleImageView setUserInteractionEnabled:YES];
    // swipe manipulate style
    // left/right
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeStyleImage:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeStyleImage:)];
    // swipe manipulate items of style
    // up/down
    // swipe manipulate
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeItemImage:)];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeItemImage:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    // adding rounded corners to profile image
    // round them corners
    _profileImageView.layer.cornerRadius = (_profileImageView.frame.size.width/2) - 5;
    _profileImageView.clipsToBounds = YES;
    //_profileImageView.layer.borderWidth = 1.0f;
   // _profileImageView.layer.borderColor = [UIColor blackColor].CGColor;
    
    _styleImageView.layer.cornerRadius = 20.0f;
    _styleImageView.clipsToBounds = YES;
   
    // Adding the swipe gesture on image view
    [_styleImageView addGestureRecognizer:swipeLeft];
    [_styleImageView addGestureRecognizer:swipeRight];
    
    [_styleImageView addGestureRecognizer:swipeUp];
    [_styleImageView addGestureRecognizer:swipeDown];
    
    self.btnShare.hidden = YES;
    self.btnLike.hidden = YES;
    [self.btnLike setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 2.0, 5.0, 5.0)];
    [self.btnLike setImage: [UIImage imageNamed:@"heart.jpg"] forState:UIControlStateNormal];
    
    // update view to show current style name
    // on click redirect user to wardrobe
    [self getCurrentSyleInfo];
    // location manager receive updates
    [self startStandardUpdates];
    
  //  [_activityImageView stopAnimating];
  //  _activityImageView.hidden = YES;
}

// function to give the effect of multiple styles
-(void) adjustUIBorder {

    CALayer* layer = [self.styleImageView layer];
    
    CALayer *rightBorder = [CALayer layer];
    rightBorder.cornerRadius = 5;
    rightBorder.masksToBounds = YES;
    rightBorder.borderColor = [UIColor darkGrayColor].CGColor;
    rightBorder.borderWidth = 2;
    rightBorder.frame = CGRectMake(layer.frame.size.height + 37, 0, 1, layer.frame.size.width - 30);
    [rightBorder setBorderColor:[UIColor blackColor].CGColor];
    
    CALayer *rightBorder1 = [CALayer layer];
    rightBorder1.cornerRadius = 5;
    rightBorder1.masksToBounds = YES;
    rightBorder1.borderColor = [UIColor darkGrayColor].CGColor;
    rightBorder1.borderWidth = 2;
    rightBorder1.frame = CGRectMake(layer.frame.size.height + 42, 0, 1, layer.frame.size.width - 30);
    [rightBorder1 setBorderColor:[UIColor blackColor].CGColor];

    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.cornerRadius = 5;
    bottomBorder.masksToBounds = YES;
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 2;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height - 1,layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
    
    
    [layer addSublayer:rightBorder];
    [layer addSublayer:rightBorder1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [_locationManager stopUpdatingLocation];
}

- (IBAction) btnUsersProfile:(id)sender {
    // show profile view for style owners
    DataInfo* info = [_stylesArr objectAtIndex:_currentStyleIndex];
    UserController *userController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
    userController.user = info.userObjectId;
    
    [self presentViewController:userController animated: NO completion:nil];
}

-(void) getLikes:(NSInteger)index type:(enum DataType) type {

    DataInfo* info = nil;
    unsigned long count = 0;
    if (type == kStyleType) {
        info = [_stylesArr objectAtIndex:index];
        count =  [StyleItems getLikesForStyle: info.objectId];
    }
    else if (type == kItemType) {
        info = [_currStyleDetail.items objectAtIndex:index];
        count =  [Item getLikesForItem: info.objectId];
    }
    info.likes = count;
    self.btnLike.hidden = NO;
    if (count > 0)
        [self.btnLike setTitle:[NSString stringWithFormat:@"%lu %@%@", count, @"aww", (count > 1) ? @"s":@""] forState:UIControlStateNormal];
    
    // showing text instead of icon for likes for now
  //  self.lblLikes.text = [NSString stringWithFormat:@"%lu %@", count, @"likes"];
}

#pragma mark - swipe style gesture left/right
// shows information on user who owns current displayed style
-(void) updateProfileForStyle:(NSInteger) index
{
    DataInfo* info = [_stylesArr objectAtIndex:index];
    // show profile image
    NSData* imageData = [User getFBProfilePic:info.userObjectId];
    if(imageData) {
        self.profileImageView.image = [UIImage imageWithData:imageData];
    }
    else
        self.profileImageView.image = [UIImage imageNamed:@"emptyProfile.png"];
    
}

-(void) showStyleAtIndex:(NSInteger) index
{
    [self.activityView startAnimating];
    DataInfo* info = [_stylesArr objectAtIndex:index];
    PFFile *thumbnail = info.imageData;
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _styleImageView.image = [UIImage imageWithData:data];

    }];
    self.lblStyleName.text = info.name;
    self.lblUserName.text = [NSString stringWithFormat:@"%@%@", @"by ", [User getFBUserName:[PFUser currentUser]]];
    // update image for owner
    [self updateProfileForStyle: index];
    // update likes count for current showing style
    [self getLikes:index type:kStyleType];
    [self.activityView stopAnimating];
}

-(void) swipeStyleImage:(UISwipeGestureRecognizer*) recognizer
{
    NSInteger index = _currentStyleIndex;
    NSInteger limit = [_stylesArr count] -  1;
    // resetting items counters
    _currStyleDetail.currentItemIndex = 0;
    self.lblItemsCount.text = @"";
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        index++;
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        index--;
    }
    
    if (index >= 0 && index <= limit)
    {
        _currentStyleIndex = index;
        [self showStyleAtIndex:_currentStyleIndex];
    }
    else
    {
        NSLog(@"Reached the end, swipe in opposite direction");
    }
    
}

-(void) showItemAtIndex:(NSInteger) index
{
    [self.activityView startAnimating];
    // get array of currentStyle showing
    DataInfo* info = [[_currStyleDetail items] objectAtIndex:index];
    PFFile *thumbnail = info.imageData;
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _styleImageView.image = [UIImage imageWithData:data];
    }];
    
    [self getLikes:index type:kItemType];
    [self.activityView stopAnimating];
}

// swipe up down items
-(void) swipeItemImage:(UISwipeGestureRecognizer*) recognizer
{
    NSInteger index = [_currStyleDetail currentItemIndex];
    NSInteger limit = _currStyleDetail.currentItemsLimit;
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp)
    {
        // first item to grab
        if (index == 0) {
            // query style and grab its items
            DataInfo* currStyle = _stylesArr[_currentStyleIndex];
            [self getItemsForStyle:[currStyle objectId]];
            limit = _currStyleDetail.currentItemsLimit;
        }
        index++;
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown)
    {
        index--;
    }
    
    if (index >= 0 && index <= limit)
    {
       [self showItemAtIndex:_currStyleDetail.currentItemIndex];
        _currStyleDetail.currentItemIndex = index;
    }
    else
    {
        NSLog(@"Reached the end, swipe in opposite direction");
    }
}

-(void) getCurrentSyleInfo {
    
    DataInfo* currStyle = [StyleItems getCurrentStyleInfo];
    if (currStyle) {
        //CGSize stringsize = [currStyle.name sizeWithFont:[UIFont systemFontOfSize:9]];
      //  [self.btnCurrStyle setFrame:CGRectMake(10,0,stringsize.width, stringsize.height)];
        [self.btnCurrStyle setTitle: currStyle.name forState: UIControlStateNormal];
    }
}
#pragma mark - location manager update
- (void) startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    
    _locationManager.delegate = self;
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 250; // meters
    
    _locationManager.allowsBackgroundLocationUpdates = YES;
    
    [_locationManager requestAlwaysAuthorization ];
    
    [_locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);

    UIAlertController* alertView = [Utility getAlertViewForMessage:NSLocalizedString(@"Error", nil) msg:NSLocalizedString(@"Failed to Get Your Location", nil) action: nil];
    [self presentViewController:alertView animated:YES completion:nil];
    
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        // keep updating current user location
        [User saveLocation: location];
        // query for nearby styles
        [self getNearbyStyles: location];
        
    }
}

-(void) getNearbyStyles:(CLLocation*) location {
    // query db for nearby items
   [StyleItems getStylesNearby:location handler:^(BOOL status, NSArray * arrStylesFound) {
    NSUInteger count = arrStylesFound.count;
    if(status == NO || count == 0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.styleImageView.bounds.size.width + 80, self.styleImageView.bounds.size.height * 2)];
        noDataLabel.text             = @"No styles nearby";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        [self.view addSubview:noDataLabel];
        
        // add default item to be added
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
        DataInfo *item = [[DataInfo alloc] init];
        item.name = @"unknown-default";
        
        [items addObject:item];
        
        _stylesArr = items;

        
        // no items found, ask user to share adylix link
        if(!self.alertShown)
        {
            self.alertShown = true;
            
            UIAlertController* alertView = [Utility getAlertViewForMessage:NSLocalizedString(@"This area is void of fashion!", nil) msg: NSLocalizedString(@"Share our App to spread the word...", nil)
                action: ^(UIAlertAction * action) {
                    UIActivityViewController* activityController = [ShareHelper shareInfo:kEmpty info:nil];
                    [self presentViewController:activityController animated:YES completion:nil];
                }];
            [self presentViewController:alertView animated:YES completion:nil];

        }
        [_activityView stopAnimating];
        return;
    }
    
    if (count > 0) {
        self.lblItemsCount.text = [NSString stringWithFormat:@"%@ %lu %@%@", @"Found", count, @"style", (count > 0) ? @"s" : @""];
        // show an image to indicate multiple styles found
        if(count > 1) {
            [self adjustUIBorder]; // adjust border UI for discovery image frame
            self.imgMoreBorder.hidden = NO;
        }
        
        NSMutableArray *styles = [[NSMutableArray alloc] initWithCapacity:arrStylesFound.count];
        for(NSDictionary *styleInfo in arrStylesFound) {
            
            DataInfo *style = [[DataInfo alloc] init];
            style.type = kStyleType;
            style.objectId = [styleInfo valueForKey:@"objectId"];
            style.userObjectId = [styleInfo valueForKey:@"userId"];
            style.name = styleInfo[@"name"];
            style.desc = styleInfo[@"description"];
            style.imageData = styleInfo[@"imageFile"];

            [styles addObject:style];
        }
        
        _stylesArr = styles;
        if([_stylesArr count] > 0) {
          self.btnShare.hidden = NO;
          self.btnLike.hidden = NO;
            // show first image
            // get profile for first style
            [self showStyleAtIndex:0];
        }
     }
       
    [self.activityView stopAnimating];

   }];
    _currStyleDetail = [[StyleDetail alloc] init];
    _currStyleDetail.currentItemIndex = 0;
    
}

-(void) getItemsForStyle:(NSString*) styleId {
    
    [self.activityView startAnimating];
    // query db for nearby items
    NSArray* arrItemsFound = [StyleItems getItemsForStyle:styleId];
    NSUInteger count = arrItemsFound.count;
    if(count == 0)
    {
        // #TODO
        // no items found, ask user to share adylix link
        // send request for more info
        return;
    }
    PFUser* user = [[StyleItems getStyleForId:styleId] valueForKey:@"userId"];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:count];
    for(NSDictionary *itemsInfo in arrItemsFound) {
        
        DataInfo *info = [[DataInfo alloc] init];
        info.type = kItemType;
        info.objectId = [itemsInfo valueForKey:@"objectId"];
        info.userObjectId = user;
        info.name = itemsInfo[@"name"];
        info.desc = itemsInfo[@"description"];
        info.imageData = itemsInfo[@"imageFile"];
        
        
        [items addObject:info];
    }
    
    _currStyleDetail.items = items;
    _currStyleDetail.currentItemIndex = 0;
    _currStyleDetail.currentItemsLimit = [_currStyleDetail.items count] - 1;
    
    self.lblItemsCount.hidden = NO;
    self.lblItemsCount.text = [NSString stringWithFormat:@"%@ %lu %@%@", @"Found", count, @"item", (count > 0) ? @"s" : @""];
    
    [self.activityView stopAnimating];
    
}

- (IBAction)btnShare:(id)sender {
    // show share block
    
    // no items nearby
    // show share action
   // [_activityImageView stopAnimating];
   // _activityImageView.hidden = YES;
    DataInfo* dataInfo;
    enum ShareType type;
    // send info to be shared
    if(_currStyleDetail.currentItemIndex == 0) {
        type = kShareStyle;
        dataInfo = [_stylesArr objectAtIndex:_currentStyleIndex];
    }
    else {
        type = kShareItem;
        dataInfo = [_currStyleDetail.items objectAtIndex:_currStyleDetail.currentItemIndex];

    }
    
    UIActivityViewController* activityController = [ShareHelper shareInfo:type info:dataInfo];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - push notify flow
- (IBAction) btnLike:(id)sender {
    DataInfo* info = nil;
    if (_currStyleDetail.currentItemIndex != 0) {
        // swiped down, user liked an item
        info = _currStyleDetail.items[_currStyleDetail.currentItemIndex];
        [StyleItems like:[_stylesArr[_currentStyleIndex] objectId] itemId:info.objectId owner: info.userObjectId];
    }
    else {
        info = _stylesArr[_currentStyleIndex];
        [StyleItems like:[_stylesArr[_currentStyleIndex] objectId] itemId:nil owner: info.userObjectId];
    }
    // get current like count and increment
    // update label
    if (info != nil) {
        unsigned int counter = info.likes + 1;
        [self.btnLike setTitle:[NSString stringWithFormat:@"%u %@%@", counter, @"aww", (counter <= 1) ? @"":@"s"] forState:UIControlStateNormal];
        
       // self.lblLikes.text = [NSString stringWithFormat:@"%u%@", counter, @" awws"];
    }
}

// -------------------------------------- payment flow ----------------------------------------------- //
// DISABLED FOR NOW
#ifdef PAY
-(void) handleResponse:(bool) success {
    
    if(!success)
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, Payment failed...try again later", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Thank you for your payment", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    
}

-(IBAction) btnPurchase:(id) sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.itemsTableView];
    NSIndexPath *indexPath = [self.itemsTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        ItemInfo *itemFound = self.itemsArray[indexPath.row];
        NSString* userId = itemFound.userObjectId;
        // get price of item
        NSString *price = itemFound.price;
        if (!userId || !price)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Item not available for Purchase", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            
            return;
        }
        // get the recepient who owns this item
        User* userQuery = [[User alloc]init];
        PFUser* recepient= [userQuery getUserForId: userId];
        // get token for recepient
        NSString* recepientId = [recepient valueForKey:@"tokenId"];
        if(!recepientId) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Item not available for Purchase", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            
            return;
        }
        
        // show payment forms
        User* userInfo = [[User alloc] init];
        NSString* tokenId = [userInfo getTokenId];
        // user have a token already
        if (tokenId != nil)
        {
            [PaymentHandler submitPayment:price tokenId: tokenId bankId: recepientId completion:^void(bool success)        {
                [self handleResponse: success];
            }];
            
        } else
        {
            
            SenderController* payController = [[SenderController alloc] init];
            payController.price = price;
            payController.recepientId = recepientId;
            payController.itemId = itemFound.objectId;
            [self.navigationController pushViewController:payController animated:NO];
        }
    }
}
#endif

@end