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


#define MERCHANTID @"merchant.com.adylix"
#define DESC_CUSTOM_TAG 1445


@interface LocateController ()

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
@end

@implementation LocateController

- (void)viewDidAppear:(BOOL)animated
{
    self.stylesArr = [[NSArray alloc]init];
    
    // show progress indicator
    UIImage *firstImage = [UIImage imageNamed:@"hat.png"];
    _activityImageView = [[UIImageView alloc]
                          initWithImage:firstImage];
    
    
    //Add more images which will be used for the animation
    _activityImageView.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"Icon@2x rot2.png"],
                                          [UIImage imageNamed:@"Icon@2x rot3.png"],
                                          [UIImage imageNamed:@"Icon@2x copy.png"],
                                          nil];
    
    
    _activityImageView.animationDuration = 0.8;
    
    
    //Position the activity image view somewhere in
    //the middle of your current view
    _activityImageView.frame = CGRectMake(
                                          self.view.frame.size.width/2
                                          -firstImage.size.width/2,
                                          self.view.frame.size.height/2
                                          -firstImage.size.height/2,
                                          firstImage.size.width,
                                          firstImage.size.height);
    
    [self.view addSubview:_activityImageView];
    
    [_activityImageView startAnimating];
    
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
    
    
    // Adding the swipe gesture on image view
    [_styleImageView addGestureRecognizer:swipeLeft];
    [_styleImageView addGestureRecognizer:swipeRight];
    
    [_styleImageView addGestureRecognizer:swipeUp];
    [_styleImageView addGestureRecognizer:swipeDown];
    
    // update view to show current style name
    // on click redirect user to wardrobe
    [self getCurrentSyleInfo];
    // location manager receive updates
    [self startStandardUpdates];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [_locationManager stopUpdatingLocation];
}

#pragma mark - swipe style gesture left/right  

-(void)updateProfileForStyle:(NSInteger)index
{
    
    DataInfo* info = [_stylesArr objectAtIndex:index];
    // adding rounded corners to profile image
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    // show profile image
    UserInfo* userInfo = [User getInfoForStyle: info.userObjectId];
    if (userInfo.profileImage) {
        [userInfo.profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(!error)
                self.profileImageView.image = [UIImage imageWithData:data];
        }];
    }
    // show likes number
}

-(void)showStyleAtIndex:(NSInteger)index
{
    DataInfo* info = [_stylesArr objectAtIndex:index];
    PFFile *thumbnail = info.imageData;
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _styleImageView.image = [UIImage imageWithData:data];
    }];
}

-(void)swipeStyleImage:(UISwipeGestureRecognizer*)recognizer
{
    NSInteger index = _currentStyleIndex;
    _currStyleDetail.currentItemIndex = 0;
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        index++;
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        index--;
    }
    
    if (index >= 0 || index < ([_stylesArr count] - 1))
    {
        _currentStyleIndex = index;
        [self showStyleAtIndex:_currentStyleIndex];
        [self updateProfileForStyle: _currentStyleIndex];
    }
    else
    {
        NSLog(@"Reached the end, swipe in opposite direction");
    }
    
}

-(void)showItemAtIndex:(NSInteger)index
{
    // get array of currentStyle showing
    DataInfo* info = [[_currStyleDetail items] objectAtIndex:index];
    PFFile *thumbnail = info.imageData;
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _styleImageView.image = [UIImage imageWithData:data];
    }];
}

// swipe up down items
-(void) swipeItemImage:(UISwipeGestureRecognizer*)recognizer
{
    NSInteger index = [_currStyleDetail currentItemIndex];
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionUp)
    {
        // first item to grab
        if (index == 0) {
            // query style and grab its items
            DataInfo* currStyle = _stylesArr[_currentStyleIndex];
            [self getItemsForStyle:[currStyle objectId]];
        }
        index++;
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown)
    {
        index--;
    }
    
    if (index >= 0 || index < ([[_currStyleDetail items] count] - 1))
    {
        _currStyleDetail.currentItemIndex = index;
        [self showItemAtIndex:_currStyleDetail.currentItemIndex];
    }
    else
    {
        NSLog(@"Reached the end, swipe in opposite direction");
    }
}

-(void) getCurrentSyleInfo {
    DataInfo* currStyle = [StyleItems getCurrentStyleInfo];
    CGSize stringsize = [currStyle.name sizeWithFont:[UIFont systemFontOfSize:9]];
    //or whatever font you're using
    [self.btnCurrStyle setFrame:CGRectMake(10,0,stringsize.width, stringsize.height)];
    [self.btnCurrStyle setTitle:currStyle.name forState:UIControlStateNormal | UIControlStateSelected];
}
#pragma mark - location manager update
- (void)startStandardUpdates
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
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
        PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLocation: location];
        [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
        [[PFUser currentUser] saveInBackground];
        
        [self getNearbyStyles: location];
    }
}

-(void) getNearbyStyles:(CLLocation*) location {
    // query db for nearby items
    NSArray* arrStylesFound = [StyleItems getStylesNearby:location];
    if(arrStylesFound.count == 0)
    {
        // add default item to be added
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:1];
        DataInfo *item = [[DataInfo alloc] init];
        item.name = @"unknown-default";
        
        [items addObject:item];
        
        self.stylesArr = items;

        
        // no items found, ask user to share adylix link
        if(!self.alertShown)
        {
            self.alertShown = true;
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Items found", nil) message:NSLocalizedString(@"Share our App to spread the word", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        

            UIActivityViewController* activityController = [ShareHelper shareInfo:kEmpty];
            [self presentViewController:activityController animated:YES completion:nil];
        }
        return;
    }
    
    NSMutableArray *styles = [[NSMutableArray alloc] initWithCapacity:arrStylesFound.count];
    for(NSDictionary *styleInfo in arrStylesFound) {
        
        DataInfo *style = [[DataInfo alloc] init];
        style.type = kStyleType;
        style.objectId = [styleInfo valueForKey:@"objectId"];
        style.userObjectId = styleInfo[@"userId"];
        style.name = styleInfo[@"name"];
        style.desc = styleInfo[@"description"];
        style.imageData = styleInfo[@"imageFile"];
        
        [styles addObject:style];
    }
    
    self.stylesArr = styles;
    
    // show first image
    PFFile *thumbnail = [[self.stylesArr objectAtIndex:0] imageData];
    
    [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _styleImageView.image = [UIImage imageWithData:data];
    }];
    
    _currStyleDetail = [[StyleDetail alloc] init];
    _currStyleDetail.currentItemIndex = 0;
    
    [_activityImageView stopAnimating];
    _activityImageView.hidden = YES;
    
}


-(void) getItemsForStyle:(NSString*) styleId {
    // query db for nearby items
    NSArray* arrItemsFound = [StyleItems getItemsForStyle:styleId];
    if(arrItemsFound.count == 0)
    {
        // no items found, ask user to share adylix link
        // send request for more info
        return;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:arrItemsFound.count];
    for(NSDictionary *itemsInfo in arrItemsFound) {
        
        DataInfo *item = [[DataInfo alloc] init];
        item.type = kItemType;
        item.objectId = [itemsInfo valueForKey:@"objectId"];
        item.userObjectId = itemsInfo[@"userObjectId"];
        item.name = itemsInfo[@"name"];
        item.desc = itemsInfo[@"description"];
        item.imageData = itemsInfo[@"imageFile"];
        
        
        [items addObject:item];
    }
    
    _currStyleDetail.items = items;
    _currStyleDetail.currentItemIndex = 0;
    
    //self.stylesArr = items;
    
    //[self.itemsTableView reloadData];
    
    [_activityImageView stopAnimating];
    _activityImageView.hidden = YES;
    
}
- (IBAction)btnShare:(id)sender {
    // show share block
    
    // no items nearby
    // show share action
    [_activityImageView stopAnimating];
    _activityImageView.hidden = YES;
    
    // #TODO: determine what type of info we are sharing style or item
    // send info to be shared
    UIActivityViewController* activityController = [ShareHelper shareInfo:kEmpty];
    [self presentViewController:activityController animated:YES completion:nil];
}
// --------------------------------------------- table view handlers ----------------------------------------------- //
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *itemTableIdentifier = @"ItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemTableIdentifier];
    }
    
    [[cell.contentView viewWithTag:DESC_CUSTOM_TAG]removeFromSuperview] ;
    // Configure the cell
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
    nameLabel.text = @"";
    
    UILabel *priceLabel = (UILabel*) [cell viewWithTag:101];
    priceLabel.text = @"";
    
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:103];
    
    CGRect contentRect = CGRectMake(priceLabel.frame.origin.x, priceLabel.frame.origin.y + 45, 240, 40);
    UILabel *descLabel = [[UILabel alloc] initWithFrame:contentRect];
    [descLabel removeFromSuperview];
    descLabel.tag = DESC_CUSTOM_TAG;
    descLabel.text = @"";
    descLabel.numberOfLines = 2;
    descLabel.textColor = [UIColor darkGrayColor];
    descLabel.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:descLabel];
    
    for(UIView *view in cell.contentView.subviews) {
        if(view.tag == 1) {
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
            [tap setNumberOfTapsRequired:1];
            [view addGestureRecognizer:tap];
        }
    }
    
    
    DataInfo *itemFound = self.stylesArr[indexPath.row];
    if(itemFound.name == @"unknown-default")
    {
        // show hat by default when no items discovered
        nameLabel.text = @"The Hat";
        descLabel.text  = @"Items discovered nearby will appear here, spread the word!";
        priceLabel.text = @"$$";
        
        UIImage *img = [UIImage imageNamed:@"Icon-40@2x.png"];
        NSData *data = UIImagePNGRepresentation(img);
        thumbnailImageView.image = [UIImage imageWithData:data];
        
    }
    else {
        nameLabel.text = itemFound.name;
        descLabel.text = itemFound.desc;
        
        PFFile *thumbnail = itemFound.imageData;
        
        [thumbnail getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(!error)
                thumbnailImageView.image = [UIImage imageWithData:data];
        }];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stylesArr count];
}

// -------------------------------------- push notify flow -------------------------------------------- //
- (IBAction)btnLike:(id)sender {
//    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.itemsTableView];
//    NSIndexPath *indexPath = [self.itemsTableView indexPathForRowAtPoint:buttonPosition];
//    if (indexPath != nil)
//    {
//        ItemInfo *itemFound = self.stylesArr[indexPath.row];
//        NSString* userId = itemFound.userObjectId;
//        NSString* itemId = itemFound.objectId;
//        
//        //  Item* item = [[Item alloc] init];
//        //  [item like:itemId ownerId:userId];
//    }
    
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

- (IBAction)btnPurchase:(id)sender {
    
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