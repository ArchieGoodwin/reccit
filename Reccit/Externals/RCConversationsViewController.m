//
//  RCConversationsViewController.m
//  Reccit
//
//  Created by Nero Wolfe on 6/16/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import "RCConversationsViewController.h"
#import "RCConversation.h"
#import "VibeViewController.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "RCLocation.h"
#import "RCVibeHelper.h"
#import "RCAppDelegate.h"
#import "UIColor-Expanded.h"
#import "NSManagedObject+NWCoreDataHelper.h"
@interface RCConversationsViewController ()

@end

@implementation RCConversationsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    _conversations =  [[[RCVibeHelper sharedInstance] getAllConversationsSortedByDate] mutableCopy];
    
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideConversationButton];
    [appDelegate hideAlert];
    
    self.navigationItem.title  = @"Message center";
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeMe)];
    self.navigationItem.rightBarButtonItem = barBtn;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.06f green:0.10f blue:0.31f alpha:1];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    

}

-(IBAction)closeMe
{
    [self dismissViewControllerAnimated:YES completion:^{
        RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showButtonForMessages];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    // Configure the cell...
    RCConversation *rcc = _conversations[indexPath.row];
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",rcc.placeName == nil ?  @"Loading place name..." : rcc.placeName];
    
    if(rcc.placeName == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getPlace:rcc cell:cell];
        });
    }
   
    
    UIButton *btnRemoveChat = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRemoveChat.frame = CGRectMake(280, 7, 27, 26);
    [btnRemoveChat setImage:[UIImage imageNamed:@"Popup-Icon-X.png"] forState:UIControlStateNormal];
    btnRemoveChat.tag = indexPath.row;
    [btnRemoveChat addTarget:self action:@selector(removeChat:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnRemoveChat];
    
    return cell;
}


-(void)getPlace:(RCConversation *)conv cell:(UITableViewCell *)cell
{
    [[RCVibeHelper sharedInstance] getPlaceFromServer:conv.placeId.integerValue conv:conv completionBlock:^(BOOL result, NSError *error) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",conv.placeName == nil ?  @"Loading place name..." : conv.placeName];
    }];
    
}


-(IBAction)removeChat:(id)sender
{
    
    UIButton *btn = (UIButton *)sender;
    
    RCConversation *rcc = _conversations[btn.tag];

    
    [[RCVibeHelper sharedInstance] removeUserFromPlaceTalk:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue] placeId:rcc.placeId.integerValue completionBlock:^(BOOL result, NSError *error) {
        
        [_conversations removeObject:rcc];
        [RCConversation deleteInContext:rcc];
        [RCConversation saveDefaultContext];
        [self.table reloadData];
    }];
    
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VibeViewController *vibe = [[VibeViewController alloc] initWithNibName:@"VibeViewController" bundle:nil];
    RCConversation *rcc = _conversations[indexPath.row];
    vibe.convsersation = rcc;
    vibe.location = [[RCLocation alloc] init];
    vibe.placeNameTxt =  [NSString stringWithFormat:@"%@",rcc.placeName == nil ?  @"Loading place name..." : rcc.placeName];
    vibe.location.ID = [rcc.placeId integerValue];
    
    [self.navigationController pushViewController:vibe animated:YES];
}

@end
