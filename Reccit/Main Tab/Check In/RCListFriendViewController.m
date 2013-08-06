//
//  RCListFriendViewController.m
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCListFriendViewController.h"
#import "RCPerson.h"
#import "RCCommonUtils.h"
#import "MBProgressHUD.h"
#import "RCDefine.h"
#import "RCAddPlaceViewController.h"
#import "UIImageView+WebCache.h"
#import "RCFriendCell.h"
#import "AFNetworking.h"
#define kRCAPIListFriend @"http://bizannouncements.com/Vega/services/app/friends.php?user=%@"
#define kRCAPIListFriendDOTNET  @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/Friends?userfbid=%@"

@interface RCListFriendViewController ()
{
    UIGestureRecognizer *cancelGesture;
    NSString *keyword;
}

@end

@implementation RCListFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    keyword = nil;
	// Do any additional setup after loading the view.
    
    self.listFriends = [[NSMutableArray alloc] init];
    self.listFriendsFilter = [[NSMutableArray alloc] init];
    
    [self.tbFriends setSeparatorColor:[UIColor clearColor]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self callAPIGetListFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Webservice

- (void)callAPIGetListFriends
{
    
    if (![RCCommonUtils isLocationServiceOn])
    {
        [RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"You must enable Location Service on App Setting to using this function!"];
        return;
    }
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlString = [NSString stringWithFormat:kRCAPIListFriendDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    NSLog(@"REQUEST URL: %@", urlString);
    
    // Start new request
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@", rO);
        
        [self.listFriends removeAllObjects];

        for (NSDictionary *rs in [rO objectForKey:@"GetFriendsResult"])
        {
            RCPerson *friend = [[RCPerson alloc] init];
            friend.name = [NSString stringWithFormat:@"%@", [rs objectForKey:@"FirstName"]];
            friend.ID = [rs objectForKey:@"FBUserId"];
            friend.photo = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",[rs objectForKey:@"FBUserId"]];
            
            if ([[rs objectForKey:@"Source"] isEqualToString:@"facebook"])
            {
                friend.source = RCFriendSourceFacebook;
            } else {
                friend.source = RCFriendSourceTwitter;
            }
            
            [self.listFriends addObject:friend];
        }
    
        
        [self.listFriends sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            RCPerson *friend1 = (RCPerson *)obj1;
            RCPerson *friend2 = (RCPerson *)obj2;
            
            return [friend1.name compare:friend2.name];
        }];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tbFriends reloadData];
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

- (IBAction)btnDoneTouched:(id)sender
{
    NSMutableArray *listFriend = [[NSMutableArray alloc] init];
    for (RCPerson *friend in self.listFriends) {
        if (friend.isMark)
        {
            [listFriend addObject:friend];
        }
    }
    
    self.fatherVc.listFriends = listFriend;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnGoTouched:(id)sender
{
    [self.listFriendsFilter removeAllObjects];
    for (RCPerson *friend in self.listFriends)
    {
        if ([friend.name rangeOfString:self.tfSearch.text options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.listFriendsFilter addObject:friend];
        }
    }
    
    [self.tbFriends reloadData];
}

#pragma mark -
#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (keyword == nil)
    return [self.listFriends count];
    
    return [self.listFriendsFilter count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCFriendCell *cell = (RCFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"RCFriendCell"];
    
    RCPerson *person = nil;
    
    if (keyword == nil  ) {
        person = [self.listFriends objectAtIndex:indexPath.row];
    } else {
        person = [self.listFriendsFilter objectAtIndex:indexPath.row];
    }

    [cell.lbName setText:person.name];
    [cell.lbName setTextColor:kRCTextColor];
    
    if (person.source == RCFriendSourceFacebook)
    {
        [cell.imgSource setImage:[UIImage imageNamed:@"ic_facebook.png"]];
    } else {
        [cell.imgSource setImage:[UIImage imageNamed:@"ic_twitter.ong"]];
    }
    //NSLog(@"%@",person.photo);
    [cell.imgAva setImageWithURL:[NSURL URLWithString:person.photo] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    cell.checkBox.tag = indexPath.row;
    
    if (person.isMark) {
        cell.checkBox.selected = YES;
    } else {
        cell.checkBox.selected = NO;
    }
    
    if (indexPath.row %2 == 0) {
        [cell.contentView setBackgroundColor:kRCTableViewCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    
    return cell;
}

- (IBAction)btnCheckBoxTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    RCPerson *person = nil;
    if (self.tfSearch.text == nil || [self.tfSearch.text length] == 0) {
        person = [self.listFriends objectAtIndex:btn.tag];
    } else {
        person = [self.listFriendsFilter objectAtIndex:btn.tag];
    }
    
    person.isMark = !person.isMark;
    [self.tbFriends reloadData];
}

#pragma mark -
#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCPerson *person = nil;
    if (self.tfSearch.text == nil || [self.tfSearch.text length] == 0) {
        person = [self.listFriends objectAtIndex:indexPath.row];
    } else {
        person = [self.listFriendsFilter objectAtIndex:indexPath.row];
    }

    person.isMark = !person.isMark;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark
#pragma mark - SearchBar delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Take string from Search Textfield and compare it with autocomplete array
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autoCompleteArray
    // The items in this array is what will show up in the table view
    
    [self.listFriendsFilter removeAllObjects];
    for (RCPerson *friend in self.listFriends)
    {
        if ([friend.name rangeOfString:substring options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.listFriendsFilter addObject:friend];
        }
    }
    if([substring isEqualToString:@""])
    {
        self.tfSearch.text = @"";
        keyword = nil;
    }
    
    [self.tbFriends reloadData];
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    keyword = substring;
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    cancelGesture = [UITapGestureRecognizer new];
    [cancelGesture addTarget:self action:@selector(backgroundTouched:)];
    [self.view addGestureRecognizer:cancelGesture];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (cancelGesture) {
        [self.view removeGestureRecognizer:cancelGesture];;
        cancelGesture = nil;
    }
}

-(void) backgroundTouched:(id) sender {
    [self.tfSearch resignFirstResponder];
}

@end
