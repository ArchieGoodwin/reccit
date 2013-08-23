//
//  RCSearchResultViewController.m
//  Reccit
//
//  Created by Lee Way on 1/31/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCSearchResultViewController.h"
#import "RCDefine.h"
#import "RCCommonUtils.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "RCLocation.h"
#import "DYRateView.h"
#import "RCLocationDetailViewController.h"
#import "AFNetworking.h"
#import "RCAppDelegate.h"
#import <MapKit/MapKit.h>
#define kAPIReccit @"http://bizannouncements.com/Vega/services/app/friendReccit.php?user=%@&%@"

#define kAPIReccitDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/Reccit?userfbid=%@&%@"

#define kAPISearchReccit  @"http://bizannouncements.com/Vega/services/app/getReccit.php?user=%@&%@"

#define kAPISearchReccitDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/KeywordSearch?userfbid=%@&%@"
#define kAPISearchFriendFac @"http://bizannouncements.com/Vega/services/app/friendFavorites.php?user=%@&%@"
#define kAPISearchFriendFavDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/Popular?userfbid=%@&%@"


//
#define kAPISearchPopular @"http://bizannouncements.com/Vega/services/app/otherPlaces.php?user=%@&%@"

@interface RCSearchResultViewController ()
{
    BOOL firstTime ;
}
@end

@implementation RCSearchResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        self.extendedLayoutIncludesOpaqueBars = YES;
        
        CGRect frame = self.view.frame;
        frame.size.height = frame.size.height - 20;
        self.view.frame = frame;
    }
    firstTime = YES;
    self.listLocationReccit = nil;
    self.listLocationFriend = nil;
    self.listLocationPopular = nil;
    self.currentTab = 1;
    [self performSelector:@selector(callAPIGetListReccit) withObject:nil afterDelay:0.1];
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
    [self.tbResult setBackgroundColor:[UIColor clearColor]];
    [self.tbResult setSeparatorColor:[UIColor clearColor]];
    
    self.searchBar.text = self.searchString;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.delegate = self;
    [self.searchBar setEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchByButton:(id)sender {
    
    if(self.searchBar.text.length > 0)
    {
        _isSearch = YES;
        
        NSString *query = [NSString stringWithFormat:@"city=%@&type=%@", self.tfLocation, self.categoryName];
        
        if ([self.searchBar.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&searchstring=%@", query, self.searchBar.text];
        }
        
        self.querySearch = query;
        self.isSurprase = NO;
        self.showTabs = NO;
        _btn1.hidden = YES;
        _btn2.hidden = YES;
        _btn3.hidden = YES;
        
        
        [self performSelector:@selector(callAPIGetListReccit) withObject:nil afterDelay:0.1];
        [self.searchBar resignFirstResponder];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Enter keyword in search field please" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
   

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if(self.searchBar.text.length > 0)
    {
        _isSearch = YES;
        
        NSString *query = [NSString stringWithFormat:@"city=%@&type=%@", self.tfLocation, self.categoryName];
        
        if ([self.searchBar.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&search=%@", query, self.searchBar.text];
        }
        
        self.querySearch = query;
        self.isSurprase = NO;
        self.showTabs = NO;
        _btn1.hidden = YES;
        _btn2.hidden = YES;
        _btn3.hidden = YES;
        
        
        [self performSelector:@selector(callAPIGetListReccit) withObject:nil afterDelay:0.1];
        [self.searchBar resignFirstResponder];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Enter keyword in search field please" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    return YES;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.isSurprase)
    {
        _imgSurprise.hidden =  NO;
        _c1.hidden  =YES;
        _c2.hidden = YES;
        _searchBar.hidden = YES;
            _btn1.hidden = YES;
            _btn2.hidden = YES;
            _btn3.hidden = YES;
        _btnSearchInside.hidden = YES;
    }
    else
    {
        _imgSurprise.hidden =  YES;
        _c1.hidden  =NO;
        _c2.hidden = NO;
        _searchBar.hidden = NO;
        if(!_showTabs)
        {
            _btn1.hidden = YES;
            _btn2.hidden = YES;
            _btn3.hidden = YES;
        }
                _btnSearchInside.hidden = NO;
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushDetail"])
    {
        RCLocationDetailViewController *detail = (RCLocationDetailViewController *)segue.destinationViewController;
        
        detail.location = sender;
    }
}

#pragma mark -
#pragma mark - Webservice

- (void)callAPIGetListReccit
{
    // Start new request
    
    NSString *urlString = [NSString stringWithFormat:_isSearch ? kAPISearchReccitDOTNET : kAPIReccitDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [self.querySearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSString *urlString = [NSString stringWithFormat:_isSearch ? kAPISearchReccit : kAPIReccit, @"958", [self.querySearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSLog(@"url for reccits: %@", urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        //NSLog(@"callAPIGetListReccit %@", rO);
        NSLog(@"reccits request done");
        self.listLocationReccit = [[NSMutableArray alloc] init];
        
        
        NSArray *listLocation = _isSearch ? [rO objectForKey:@"KeywordSearchResult"] : [rO objectForKey:@"ReccitResult"];
        if (listLocation != [NSNull null])
        {
            for (NSDictionary *locationDic in listLocation)
            {
                RCLocation *l = [RCCommonUtils getLocationFromDictionary:locationDic];
                if(l)
                {
                    [_listLocationReccit addObject:[RCCommonUtils getLocationFromDictionary:locationDic]];
                    
                }
            }
        }
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([self.listLocationReccit count] == 0)
        {
            firstTime = NO;
            //[RCCommonUtils showMessageWithTitle:nil andContent:@"No result for this searching."];
        }
        [self.tbResult reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:error.description];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
    
}

- (void)callAPIGetListFriendFav
{
    // Start new request
    NSString *urlString = [NSString stringWithFormat:kAPISearchFriendFavDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], self.querySearch];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"url for callAPIGetListFriendFav: %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"favs: %@", rO);
        self.listLocationFriend = [[NSMutableArray alloc] init];
        
        NSArray *listLocation = [rO objectForKey:@"PopularResult"];
        if (listLocation != [NSNull null]){
            for (NSDictionary *locationDic in listLocation)
            {
                //NSLog(@"%@", locationDic);
                RCLocation *l = [RCCommonUtils getLocationFromDictionary:locationDic];
                if(l)
                {
                    [_listLocationFriend addObject:[RCCommonUtils getLocationFromDictionary:locationDic]];
                    
                }
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"friendsCount" ascending:NO];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            _listLocationFriend = [[_listLocationFriend sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([self.listLocationFriend count] == 0)
        {
            [RCCommonUtils showMessageWithTitle:nil andContent:@"No result for this searching."];
        }
        [self.tbResult reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
    
    
}

- (void)callAPIGetListPopular
{
    // Start new request
    NSString *urlString = [NSString stringWithFormat:kAPISearchPopular, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], self.querySearch];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"url for callAPIGetListPopular: %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"popular: %@", rO);
        self.listLocationPopular = [[NSMutableArray alloc] init];
        NSArray *listLocation = [rO objectForKey:@"Reccits"];
        if (listLocation != [NSNull null]){
            
            for (NSDictionary *locationDic in listLocation)
            {
                
                RCLocation *l = [RCCommonUtils getLocationFromDictionary:locationDic];
                if(l)
                {
                    [_listLocationPopular addObject:[RCCommonUtils getLocationFromDictionary:locationDic]];
                    
                }
            }
        }
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([self.listLocationPopular count] == 0)
        {
            [RCCommonUtils showMessageWithTitle:nil andContent:@"No result for this searching."];
        }
        [self.tbResult reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
    
    
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnBackTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnMenuTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    self.currentTab = btn.tag - 1000;
    
    if (self.currentTab == 1)
    {
        if (self.listLocationReccit == nil)
        {
            [self callAPIGetListReccit];
        } else {
            if ([self.listLocationReccit count] == 0)
            {
                //[RCCommonUtils showMessageWithTitle:nil andContent:@"No result for this searching."];
            }
        }
    }
    
    if (self.currentTab == 2)
    {
        if (self.listLocationFriend == nil)
        {
            [self callAPIGetListFriendFav];
        } else {
            if ([self.listLocationFriend count] == 0)
            {
                [RCCommonUtils showMessageWithTitle:nil andContent:@"No result for this searching."];
            }
        }
    }
    
    if (self.currentTab == 3)
    {
        if (self.listLocationPopular == nil)
        {
            [self callAPIGetListPopular];
        } else {
            if ([self.listLocationPopular count] == 0)
            {
                [RCCommonUtils showMessageWithTitle:nil andContent:@"No result for this searching."];
            }
        }
    }
    
    [self.tbResult reloadData];
}


#pragma mark -
#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.currentTab) {
        case 1:
            if(self.listLocationReccit.count > 0)
            {
                return [self.listLocationReccit count];

            }
            else
            {
                if(!_isSearch && !firstTime)
                {
                    return 1;
                }
                return 0;
            }
        case 2:
            return [self.listLocationFriend count];
        case 3:
            return [self.listLocationPopular count];
    }
    return 0;
}


-(NSString *)distanceStringFromPoint:(RCLocation *)myLocation
{
    CFLocaleRef userLocaleRef = CFLocaleCopyCurrent();
    //CFShow(CFLocaleGetIdentifier(userLocaleRef));
    NSString *loc = (NSString *)CFLocaleGetIdentifier(userLocaleRef);
    CFRelease(userLocaleRef);
    double kilometers = myLocation.distance;
    //kilometers = 1.4;
    double res = 0.0;
    if([loc isEqualToString:@"en_US"] || [loc isEqualToString:@"en_GB"])
    {
        loc = @"en_US";
    }
    if([loc isEqualToString:@"en_US"])
    {
        res = kilometers / 1609.344;
    }
    else
    {
        res = kilometers / 1000;
    }
    
    NSString *str  = @"";
    if(res > 1)
    {
        str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.1f %@", res, [loc isEqualToString:@"en_US"] ? @"miles" : @"km"]];
    }
    else
    {
        str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.1f %@", (res * ([loc isEqualToString:@"en_US"] ? 5280 : 1000)), [loc isEqualToString:@"en_US"] ? @"feets" : @"m"]];
    }
    return str;
}

-(NSString *)distanceStringFromPoint:(double)lat lng:(double)lng
{
    CLLocationDegrees longitude = lng;
    CLLocationDegrees latitude = lat;
    CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocationCoordinate2D usrLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate] getCurrentLocation];
    CLLocation * userLocation = [[CLLocation alloc] initWithLatitude:usrLocation.latitude longitude:usrLocation.longitude];
    
    CFLocaleRef userLocaleRef = CFLocaleCopyCurrent();
    //CFShow(CFLocaleGetIdentifier(userLocaleRef));
    NSString *loc = (NSString *)CFLocaleGetIdentifier(userLocaleRef);
    CFRelease(userLocaleRef);
    
    //NSLog(@"%f  %f   %f   %f", placeLocation.coordinate.latitude, placeLocation.coordinate.longitude, userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    double kilometers = [userLocation distanceFromLocation:placeLocation];
    //kilometers = 1.4;
    double res = 0.0;
    if([loc isEqualToString:@"en_US"] || [loc isEqualToString:@"en_GB"])
    {
        loc = @"en_US";
    }
    if([loc isEqualToString:@"en_US"])
    {
        res = kilometers / 1609.344;
    }
    else
    {
        res = kilometers / 1000;
    }

    NSString *str  = @"";
    if(res > 1)
    {
        str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.1f %@", res, [loc isEqualToString:@"en_US"] ? @"miles" : @"km"]];
    }
    else
    {
        str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.1f %@", (res * ([loc isEqualToString:@"en_US"] ? 5280 : 1000)), [loc isEqualToString:@"en_US"] ? @"feets" : @"m"]];
    }
    return str;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.listLocationReccit.count > 0)
    {
        return 80;
    }
    
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    
    RCLocation *location = nil;
    switch (self.currentTab) {
        case 1:
            
            if(self.listLocationReccit.count > 0)
            {
                location = [self.listLocationReccit objectAtIndex:indexPath.row];

            }
            else
            {
                if(!_isSearch)
                {
                    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
                    [(UILabel *)[cell viewWithTag:300] setText:@"We don't have any Reccits for you right now, but check back as you and your friends rate more places"];
                    return cell;
                }
                
            }
            
            break;
        case 2:
            location = [self.listLocationFriend objectAtIndex:indexPath.row];
            break;
        case 3:
            location = [self.listLocationPopular objectAtIndex:indexPath.row];
            break;
    }
    
    
   
    ((UIImageView *)[cell viewWithTag:995]).hidden = YES;

    if(self.currentTab == 1)
    {
        if(!self.showTabs && !self.isSurprase)
        {
            ((UIImageView *)[cell viewWithTag:995]).hidden = YES;
            ((UILabel *)[cell viewWithTag:997]).hidden = YES;

        }
        else
        {
            ((UILabel *)[cell viewWithTag:997]).hidden = NO;
            
            
            
            
            if(location.reccitCount > 0)
            {
                ((UIImageView *)[cell viewWithTag:995]).hidden = NO;
                if(location.reccitCount == 1)
                {
                    [(UILabel *)[cell viewWithTag:997] setText:[NSString stringWithFormat:@"%i reccit", location.reccitCount]];
                }
                else
                {
                    [(UILabel *)[cell viewWithTag:997] setText:[NSString stringWithFormat:@"%i reccits", location.reccitCount]];
                    
                }
                
                
            }
            else
            {
                [(UILabel *)[cell viewWithTag:997] setText:@""];
            }
        }
        
        
        
    }
    else
    {
        ((UILabel *)[cell viewWithTag:997]).hidden = YES;
    }

    [(UILabel *)[cell viewWithTag:505] setText:[self distanceStringFromPoint:location]];
    
    
    [(UILabel *)[cell viewWithTag:1001] setText:location.name];
    
    DYRateView *rateView = (DYRateView *)[cell viewWithTag:1002];
    
    [rateView setRate:location.rating];
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    
    for (int i = 0; i < 6; ++i)
    {
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:2001+i];
        imgView.image = nil;
    }
    
    if(self.currentTab == 1)
    {
        if(location.listFriends.count > 0)
        {
            
            if(location.listFriends.count == 1)
            {
                [(UILabel *)[cell viewWithTag:996] setText:[NSString stringWithFormat:@"%i of your friends has been here", location.listFriends.count]];
                
            }
            else
            {
                [(UILabel *)[cell viewWithTag:996] setText:[NSString stringWithFormat:@"%i of your friends have been here", location.listFriends.count]];
                
            }
            
            
            for (int i = 0; i < [location.listFriends count]; ++i)
            {
                NSString *imgUrl = [location.listFriends objectAtIndex:i];
                if(imgUrl != [NSNull null])
                {
                    UIImageView *imgView = (UIImageView *)[cell viewWithTag:2001+i];
                    [imgView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = imgView.frame;
                    [btn setBackgroundColor:[UIColor clearColor]];
                    btn.tag = indexPath.row;
                    [btn addTarget:self action:@selector(showFriendName:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:btn];
                }

            }
            
        }
        else
        {
            [(UILabel *)[cell viewWithTag:996] setText:@""];
        }
        
        
    }
    else
    {
        if(location.listFriends.count > 0)
        {
            
            if(location.listFriends.count == 1)
            {
                [(UILabel *)[cell viewWithTag:996] setText:[NSString stringWithFormat:@"%i person has been here", location.listFriends.count]];
                
            }
            else
            {
                [(UILabel *)[cell viewWithTag:996] setText:[NSString stringWithFormat:@"%i people have been here", location.listFriends.count]];
                
            }
            
            
            for (int i = 0; i < [location.listFriends count]; ++i)
            {
                NSString *imgUrl = [location.listFriends objectAtIndex:i];
                if(imgUrl != [NSNull null])
                {
                    UIImageView *imgView = (UIImageView *)[cell viewWithTag:2001+i];
                    [imgView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = imgView.frame;
                    [btn setBackgroundColor:[UIColor clearColor]];
                    btn.tag = indexPath.row;
                    [btn addTarget:self action:@selector(showFriendName:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:btn];
                }
                
            }
            
        }
        else
        {
            [(UILabel *)[cell viewWithTag:996] setText:@""];
        }
    }
    
    
    

    
    return cell;
}

-(IBAction)showFriendName:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    RCLocation *location = nil;
    switch (self.currentTab) {
        case 1:
            location = [self.listLocationReccit objectAtIndex:btn.tag];
            break;
        case 2:
            location = [self.listLocationFriend objectAtIndex:btn.tag];
            break;
        case 3:
            location = [self.listLocationPopular objectAtIndex:btn.tag];
            break;
    }
    UITableViewCell *cell = [self.tbResult cellForRowAtIndexPath:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
    UILabel *lbl = (UILabel *)[cell viewWithTag:996];
    
    if(self.currentTab == 1)
    {
        if(btn.frame.origin.x == 10)
        {
            lbl.text = [location.listFriendsName[0] objectForKey:@"FirstName"];
        }
        if(btn.frame.origin.x == 46)
        {
            lbl.text = [location.listFriendsName[1] objectForKey:@"FirstName"];
        }
        if(btn.frame.origin.x == 82)
        {
            lbl.text = [location.listFriendsName[2] objectForKey:@"FirstName"];
        }
        if(btn.frame.origin.x == 118)
        {
            lbl.text = [location.listFriendsName[3] objectForKey:@"FirstName"];
        }
        if(btn.frame.origin.x == 154)
        {
            lbl.text = [location.listFriendsName[4] objectForKey:@"FirstName"];
        }
        if(btn.frame.origin.x == 190)
        {
            lbl.text = [location.listFriendsName[5] objectForKey:@"FirstName"];
        }
    }
    else
    {
        if(btn.frame.origin.x == 10)
        {
            lbl.text =  [NSString stringWithFormat:@"%@ (friends with %@)",[location.listFriendsName[0] objectForKey:@"FirstName"], [location.listFriendsName[0] objectForKey:@"Relation"]];
        }
        if(btn.frame.origin.x == 46)
        {
            lbl.text =  [NSString stringWithFormat:@"%@ (friends with %@)",[location.listFriendsName[1] objectForKey:@"FirstName"], [location.listFriendsName[1] objectForKey:@"Relation"]];
        }
        if(btn.frame.origin.x == 82)
        {
            lbl.text =  [NSString stringWithFormat:@"%@ (friends with %@)",[location.listFriendsName[2] objectForKey:@"FirstName"], [location.listFriendsName[2] objectForKey:@"Relation"]];
        }
        if(btn.frame.origin.x == 118)
        {
            lbl.text =  [NSString stringWithFormat:@"%@ (friends with %@)",[location.listFriendsName[3] objectForKey:@"FirstName"], [location.listFriendsName[3] objectForKey:@"Relation"]];
        }
        if(btn.frame.origin.x == 154)
        {
            lbl.text =  [NSString stringWithFormat:@"%@ (friends with %@)",[location.listFriendsName[4] objectForKey:@"FirstName"], [location.listFriendsName[4] objectForKey:@"Relation"]];
        }
        if(btn.frame.origin.x == 190)
        {
            lbl.text =  [NSString stringWithFormat:@"%@ (friends with %@)",[location.listFriendsName[5] objectForKey:@"FirstName"], [location.listFriendsName[5] objectForKey:@"Relation"]];
        }
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCLocation *location = nil;
    switch (self.currentTab) {
        case 1:{
            if(self.listLocationReccit.count > 0)
            {
                location = [self.listLocationReccit objectAtIndex:indexPath.row];

            }
            break;}
        case 2:
        {
            if(self.listLocationFriend.count > 0)
            {
                location = [self.listLocationFriend objectAtIndex:indexPath.row];

            }
            break;}
        case 3:{
            if(self.listLocationPopular.count > 0)
            {
                location = [self.listLocationPopular objectAtIndex:indexPath.row];

            }
            
            break;
        }
    }
    if(location != nil)
    {
        location.type = self.category;
        NSLog(@"%@ %@ %@", location.name, location.type, location.category);
        [self performSegueWithIdentifier:@"PushDetail" sender:location];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (void)viewDidUnload {
    [self setLblNumberOfReccits:nil];
    [self setLblNumberOfFriends:nil];
    [self setImgSurprise:nil];
    [self setC1:nil];
    [self setC2:nil];
    [self setSearchBar:nil];
    [self setBtn1:nil];
    [self setBtn2:nil];
    [self setBtn3:nil];
    [self setBtnSearchInside:nil];
    [super viewDidUnload];
}
@end
