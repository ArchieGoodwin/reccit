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
#import "RCAppDelegate.h"
#import "JSTokenField.h"
#import "JSTokenButton.h"
#define kRCAPIListFriend @"http://bizannouncements.com/Vega/services/app/friends.php?user=%@"
#define kRCAPIListFriendDOTNET  @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/Friends?userfbid=%@"

@interface RCListFriendViewController ()
{
    UIGestureRecognizer *cancelGesture;
    NSMutableArray *_toRecipients;
    JSTokenField *_toField;

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
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
        
        //}];
        
    }
    else
    {
        CGRect frame = self.btnDone.frame;
        frame.origin.y = frame.origin.y + 54;
        self.btnDone.frame = frame;
        
        frame = self.tbFriends.frame;
        frame.size.height = frame.size.height + 50;
        self.tbFriends.frame = frame;
    }
    
    _keyword = nil;
	// Do any additional setup after loading the view.
    
    self.listFriends = [[NSMutableArray alloc] init];
    self.listFriendsFilter = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTokenFieldFrameDidChange:)
												 name:JSTokenFieldFrameDidChangeNotification
											   object:nil];
	
	_toRecipients = [[NSMutableArray alloc] init];

	
	_toField = [[JSTokenField alloc] initWithFrame:CGRectMake(40, 10, 270, 31)];
    [_toField textField].placeholder = @"Search friends";
	[[_toField label] setText:@""];
	[_toField setDelegate:self];
	[self.view addSubview:_toField];
    
    
    [self.tbFriends setSeparatorColor:[UIColor clearColor]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideConversationButton];
    [appDelegate hideAlert];
    
    [self callAPIGetListFriends];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removePerson:(RCPerson *)person
{
    [_toField removeTokenForString:person.name];

}

-(BOOL)checkPerson:(RCPerson *)person
{
    
    for(JSTokenButton *pers in _toField.tokens)
    {
        if([pers.titleLabel.text isEqualToString:person.name])
        {
            return YES;
            
        }
    }
    return NO;
}


#pragma mark -
#pragma mark JSTokenFieldDelegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
	NSDictionary *recipient = [NSDictionary dictionaryWithObject:obj forKey:title];
	[_toRecipients addObject:recipient];
	NSLog(@"Added token for < %@ : %@ >\n%@", title, obj, _toRecipients);
    
}

-(void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj
{
    NSLog(@"Deleted token %@", _toRecipients);
    
    for(RCPerson *pers in self.listFriends)
    {
        if (pers.isMark && [pers isEqual:obj])
        {
            //[self.listFriends removeObject:pers];
            pers.isMark = !pers.isMark;
            [self.tbFriends reloadData];
            break;
        }
    }
    
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{
	[_toRecipients removeObjectAtIndex:index];
	NSLog(@"Deleted token %d\n%@", index, _toRecipients);
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    /*NSMutableString *recipient = [NSMutableString string];
	
	NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
    NSString *rawStr = [[tokenField textField] text];
	for (int i = 0; i < [rawStr length]; i++)
	{
		if (![charSet characterIsMember:[rawStr characterAtIndex:i]])
		{
			[recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
		}
	}
    
    
    
    */
    [tokenField textField].text = @"";
    if(self.listFriendsFilter.count == 1)
    {
        RCPerson *person = nil;
        person = [self.listFriendsFilter objectAtIndex:0];
        
        
        person.isMark = !person.isMark;
        
        [_toField addTokenWithTitle:person.name representedObject:person];
        
        [[_toField textField] resignFirstResponder];
    }

    
    [tokenField textField].text = @"";
    _keyword = nil;
    [self.tbFriends reloadData];
    
    return NO;
}

- (void)handleTokenFieldFrameDidChange:(NSNotification *)note
{
	if ([[note object] isEqual:_toField])
	{
		[UIView animateWithDuration:0.0
						 animations:^{
                             
                             CGRect frame = self.tbFriends.frame;
                             NSLog(@"BEFORE %@", NSStringFromCGRect(frame));
                             frame.origin.y = [_toField frame].size.height + [_toField frame].origin.y + 5;
                             frame.size.height = self.view.frame.size.height - 8 - [_toField frame].size.height - 5 - 70;
                             
                             NSLog(@"AFTER %@", NSStringFromCGRect(frame));
                             self.tbFriends.frame = frame;
							 //[_ccField setFrame:CGRectMake(0, [_toField frame].size.height + [_toField frame].origin.y, [_ccField frame].size.width, [_ccField frame].size.height)];
						 }
						 completion:nil];
	}
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[_toField textField] resignFirstResponder];
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
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showButtonForMessages];
    
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
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showButtonForMessages];
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
    if (_keyword == nil)
    return [self.listFriends count];
    
    return [self.listFriendsFilter count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCFriendCell *cell = (RCFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"RCFriendCell"];
    
    RCPerson *person = nil;
    
    if (_keyword == nil  ) {
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
    if (_keyword == nil) {
        person = [self.listFriends objectAtIndex:btn.tag];
    } else {
        person = [self.listFriendsFilter objectAtIndex:btn.tag];
        _keyword = nil;
    }

    person.isMark = !person.isMark;
    
    if(![self checkPerson:person])
    {
        [_toField addTokenWithTitle:person.name representedObject:person];
        [_toField textField].text = @"";
    }
    else
    {
        [self removePerson:person];
        [_toField textField].text = @"";
    }

    [[_toField textField] resignFirstResponder];
    [self.tbFriends reloadData];
}

#pragma mark -
#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCPerson *person = nil;
    if (_keyword == nil) {
        person = [self.listFriends objectAtIndex:indexPath.row];
    } else {
        person = [self.listFriendsFilter objectAtIndex:indexPath.row];
        _keyword = nil;
    }
    
    
    person.isMark = !person.isMark;
    //[_toField addTokenWithTitle:person.name representedObject:person];
    //[_toField textField].text = @"";
    if(![self checkPerson:person])
    {
        [_toField addTokenWithTitle:person.name representedObject:person];
        [_toField textField].text = @"";
    }
    else
    {
        [self removePerson:person];
        [_toField textField].text = @"";
    }
    
   
    
    [[_toField textField] resignFirstResponder];
    
     [self.tbFriends reloadData];
    //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
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
        _keyword = nil;
    }
    
    [self.tbFriends reloadData];
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    _keyword = substring;
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
