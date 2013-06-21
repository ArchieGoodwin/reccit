//
//  ViewController.m

//

#import "VibeViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "RCVibeHelper.h"
#import "RCDefine.h"
@implementation VibeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _placeTitle.title = self.location.name;
   

    if(self.navigationController)
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO]; // hides
    }
    else
    {
        //hide:  barbuttonItem.width = 0.01;
        //show:  barbuttonItem.width = 0; //(0 defaults to text width)

        NSMutableArray *items = [_bar.items mutableCopy];
        [items removeObject:_btnBack];
        _bar.items = items;
        
       // _btnBack.width = 0.01;
    }
    
    //bubbleData = [[RCVibeHelper sharedInstance] getConversationFromArray:@[@{@"UserId":@577},@{@"UserId":@577}] myUserId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    bubbleData = [[RCVibeHelper sharedInstance] getBubblesFromConversation:self.convsersation myUserId:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue]];

    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    [bubbleTable reloadData];

    
    [self refreshConversaton];
    
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)refreshConversaton
{
    [[RCVibeHelper sharedInstance] getConversationFromServer:self.location.ID completionBlock:^(RCConversation *result, NSError *error) {
        if(result != nil)
        {
            self.convsersation = result;
            bubbleData = [[RCVibeHelper sharedInstance] getBubblesFromConversation:self.convsersation myUserId:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue]];
            [bubbleTable reloadData];
            
            if (bubbleTable.contentSize.height > bubbleTable.frame.size.height)
            {
                CGPoint offset = CGPointMake(0, bubbleTable.contentSize.height - bubbleTable.frame.size.height);
                [bubbleTable setContentOffset:offset animated:YES];
            }
        }
       

        
    }];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}

#pragma mark - Actions

- (IBAction)sayPressed:(id)sender
{
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;

    
    [[RCVibeHelper sharedInstance] sendMessageFromUserId:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue] messageText:textField.text placeId:self.location.ID subj:@"" completionBlock:^(BOOL result, NSError *error) {
        //
        
        if(result)
        {
            [self refreshConversaton];

        }
        
    }];
    
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithText:textField.text date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    [bubbleData addObject:sayBubble];
    [bubbleTable reloadData];
    
    textField.text = @"";
    [textField resignFirstResponder];
    
    
    if (bubbleTable.contentSize.height > bubbleTable.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, bubbleTable.contentSize.height - bubbleTable.frame.size.height);
        [bubbleTable setContentOffset:offset animated:YES];
    }
    
    
    
}

- (void)viewDidUnload {
    [self setBtnBack:nil];
    [self setBar:nil];
    [self setPlaceTitle:nil];
    [super viewDidUnload];
}
@end