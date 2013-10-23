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
#import "RCMessage.h"
#import "NSBubbleData.h"
@interface RCConversationsViewController ()

@end

@implementation RCConversationsViewController

-(BOOL)prefersStatusBarHidden
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
    self.conversations =  [[[RCVibeHelper sharedInstance] getAllConversationsSortedByDate] mutableCopy];

    [self.table reloadData];

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
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    // Configure the cell...
    RCConversation *rcc = self.conversations[indexPath.row];
    

    
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
    
    NSLog(@"step 0 %i", indexPath.row);


    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",rcc.placeName == nil ?  @"Loading place name..." : rcc.placeName];
    
    NSLog(@"step 1 %i  %@", indexPath.row, rcc.messagesCount);

    
    if([rcc respondsToSelector:@selector(messagesCount)])
    {
        NSLog(@"step 1 %i  %i", indexPath.row, [rcc.messagesCount integerValue]);

        if([rcc.messagesCount integerValue] > 0)
        {
            NSArray *bubbleData = [[RCVibeHelper sharedInstance] getMessagesSorted:rcc];
            
            RCMessage *mess = [bubbleData objectAtIndex:0];
            
            
            if(mess.user.userId.integerValue != [[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue])
            {
                UIImageView *newMess = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageCenter-AlertButton.png"]];
                newMess.frame = CGRectMake(210, 7, 60, 27);
                newMess.tag = 701;
                [cell.contentView addSubview:newMess];
                
                UILabel *lblMess = [[UILabel alloc] initWithFrame:CGRectMake(218, 10, 45, 20)];
                lblMess.backgroundColor = [UIColor clearColor];
                lblMess.textColor = [UIColor whiteColor];
                lblMess.font = [UIFont systemFontOfSize:12];
                lblMess.text = [NSString stringWithFormat:@"%i new", [rcc.messagesCount integerValue]];
                lblMess.tag = 702;
                [cell.contentView addSubview:lblMess];
                NSLog(@"step 2 %i", indexPath.row);
                
            }
            
            
            
        }
        else
        {
            if([cell.contentView viewWithTag:701])[[cell.contentView viewWithTag:701] removeFromSuperview];
            
            if([cell.contentView viewWithTag:702])[[cell.contentView viewWithTag:702] removeFromSuperview];
        }
    }
    
        

    
    
    
    return cell;
}


-(void)getPlace:(RCConversation *)conv cell:(UITableViewCell *)cell
{
    if(conv.placeId != nil)
    {
        [[RCVibeHelper sharedInstance] getPlaceFromServer:conv.placeId.integerValue conv:conv completionBlock:^(NSString *result, NSError *error) {
             if(cell != nil)
             {
                 
                 cell.textLabel.text = [NSString stringWithFormat:@"%@",result == nil ?  @"Loading place name..." : result];

             }
        }];
    }
   
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    VibeViewController *vibe = [[VibeViewController alloc] initWithNibName:@"VibeViewController" bundle:nil];
    RCConversation *rcc = self.conversations[indexPath.row];
    rcc.lastDate = [NSDate date];
    rcc.messagesCount = @"0";
    [RCConversation saveDefaultContext];
    vibe.convsersation = rcc;
    vibe.location = [[RCLocation alloc] init];
    vibe.placeNameTxt =  [NSString stringWithFormat:@"%@",rcc.placeName == nil ?  @"Loading place name..." : rcc.placeName];
    vibe.location.ID = [rcc.placeId integerValue];
    
    [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
    [self.navigationController pushViewController:vibe animated:YES];
}

@end
