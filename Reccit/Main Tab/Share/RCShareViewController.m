//
//  RCShareViewController.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCShareViewController.h"
#import "UIImageView+WebCache.h"
#import "RCDefine.h"
#import "RCShareCell.h"
#import "RCDataHolder.h"
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "RCLocation.h"
#import "RCMyReviewViewController.h"
#import "AFNetworking.h"
#import "RCAppDelegate.h"
#import "RCReviewInDetailsViewController.h"
#define kAPIGetGenres @"http://bizannouncements.com/Vega/services/app/cuisines.php"
#define kAPIListReview @"http://bizannouncements.com/Vega/services/app/profile.php?user=%@&city=%@&rating=%@&type=%@&genre=%@"

@interface RCShareViewController ()
{
    NSMutableArray *types;
    RCReviewInDetailsViewController *reviewVc;
}

@end

@implementation RCShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(showVibe) withObject:nil afterDelay:0.3];
    
}

-(void)showVibe
{
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate showButtonForMessages];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        CGRect rect =  self.btnShare.frame;
        rect.origin.y = rect.origin.y - 40;
        self.btnShare.frame = rect;
        
        
        rect = self.tbReview.frame;
        rect.size.height = rect.size.height - 40;
        self.tbReview.frame = rect;
        
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
	// Do any additional setup after loading the view.
   /* if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        self.extendedLayoutIncludesOpaqueBars = YES;
        
        CGRect frame = self.view.frame;
        frame.size.height = frame.size.height - 20;
        frame.origin.y = 20;
        self.view.frame = frame;
    }
*/
    
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    self.tfGenre.inputView = self.picker;
    self.tfGenre.inputAccessoryView = self.toolbarDone;
    self.tfPrice.inputView = self.picker;
    self.tfPrice.inputAccessoryView = self.toolbarDone;
    self.tfType.inputView = self.picker;
    self.tfType.inputAccessoryView = self.toolbarDone;
    self.tfCity.inputView = self.picker;
    self.tfCity.inputAccessoryView = self.toolbarDone;
    self.tfCity.delegate = self;
    
   /* if([RCCommonUtils isIphone5])
    {
        CGRect frame = _bkgImage.frame;
        frame.size.height = 490;
        _bkgImage.frame = frame;
        
        frame = _btnShare.frame;
        frame.origin.y = 478;
        _btnShare.frame = frame;
        
        frame = self.tbReview.frame;
        frame.size.height = 290;
        self.tbReview.frame = frame;
    }
    
    */
}


-(BOOL)isGEnreExistInList:(NSString *)genre
{
    for(RCLocation *location in self.listReview)
    {
        if ([location.genre isEqualToString:genre]) return YES;

    }
    return NO;
}



-(BOOL)isLocationHasThisGenre:(NSString *)genre loc:(RCLocation *)loc
{
    if(!genre) return YES;

    NSArray *genreSplit = [loc.genre componentsSeparatedByString:@","];
    for(NSString *str in genreSplit)
    {
        if([str isEqualToString:genre])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isPriceRangeTheSame:(NSString *)price loc:(RCLocation *)loc
{
    if(!price)return YES;
    
    if([loc.priceRange integerValue] == price.length)
    {
        return YES;
    }
    
    
    return NO;
}


-(BOOL)isLocationHasThisCity:(NSString *)city loc:(RCLocation *)loc
{
    if(!city)return YES;

    if([loc.city isEqualToString:city])
    {
        return YES;
    }


    return NO;
}

-(BOOL)isLocationOFType:(NSString *)type loc:(RCLocation *)loc
{
    if(!type)return YES;
    
    if([self isTypeInLocation:type loc:loc])
    {
        return YES;
    }
    //if([loc.category isEqualToString:type])
    //{
     //   return YES;
    //}
    
    return NO;
}





-(BOOL)isTypeInLocation:(NSString *)type loc:(RCLocation *)loc
{

    NSMutableArray *allTypesSplit = [NSMutableArray new];
    
    NSArray *typeSplit = [loc.category componentsSeparatedByString:@","];
    
    for(NSString *split in typeSplit)
    {
        NSArray *temp = [split componentsSeparatedByString:@" "];

        for(NSString *s in temp)
        {
            [allTypesSplit addObject:s];
        }
    }

   if([type isEqualToString:@"eat"])
   {
       for(NSString *split in allTypesSplit)
       {

           if([[split lowercaseString] isEqualToString:@"restaurant"])
           {
               return YES;
           }
           if([[split lowercaseString] isEqualToString:@"food"])
           {
               return YES;
           }
       }
   }
    if([type isEqualToString:@"drink"])
    {
        for(NSString *split in allTypesSplit)
        {
            if([[split lowercaseString] isEqualToString:@"bar"])
            {
                return YES;
            }
            if([[split lowercaseString] isEqualToString:@"nightlife"])
            {
                return YES;
            }
            if([[split lowercaseString] isEqualToString:@"club"])
            {
                return YES;
            }
        }
    }
    if([type isEqualToString:@"stay"])
    {
        for(NSString *split in allTypesSplit)
        {
            if([[split lowercaseString] isEqualToString:@"hotel"])
            {
                return YES;
            }
            if([[split lowercaseString] isEqualToString:@"travel"])
            {
                return YES;
            }
            if([[split lowercaseString] isEqualToString:@"recreation"])
            {
                return YES;
            }
        }
    }
    return NO;

}

- (void)loadGerne
{
    NSMutableArray *genres = [NSMutableArray new];
    for(RCLocation *loc in self.listReview)
    {
        NSArray *genreSplit = [loc.genre componentsSeparatedByString:@","];
        for(NSString *split in genreSplit)
        {
            if(![split isEqualToString:@"Bar"] && ![split isEqualToString:@"Hotel"] && ![split isEqualToString:@"Restaurant"] && ![split isEqualToString:@""] && ![split isEqualToString:@"Nightclub"] && ![split isEqualToString:@"Sports Bar"])
            {
                BOOL identicalStringFound = NO;
                for(NSString *genre in genres)
                {
                    if([genre isEqualToString:split])
                    {
                        identicalStringFound = YES;
                        break;
                    }
                }
                if(!identicalStringFound)
                {
                    [genres addObject:split];
                }
            }
            
        }
    }
    [RCDataHolder setListCountry:genres];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startRequest];

    
    /*if ([RCDataHolder getListCountry] == nil)
    {
        [self loadGerne];
    }*/
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushMyReview"])
    {
        RCMyReviewViewController *review = (RCMyReviewViewController *)segue.destinationViewController;
        
        review.location = sender;
    }
}

- (void)startRequest
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    NSString *urlString = [NSString stringWithFormat:@"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/GetProfile?userfbid=%@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"shre link: %@", urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSLog(@"share response: %@", rO);
        self.listReview  = [[NSMutableArray alloc] init];
        self.listCity = [[NSMutableArray alloc] init];
        for (NSDictionary *locationDic in [rO objectForKey:@"GetProfileResult"])
        {
            RCLocation *location =  [RCCommonUtils getLocationFromDictionary:locationDic];
            
            if(location)
            {
                //NSLog(@"COMMENT %@", location.comment);
                //NSLog(@"category %@", location.category);
                [self.listReview addObject:location];
                
                if ([location.city isEqualToString:@""]) continue;
                
                BOOL isExist = FALSE;
                for (NSString *str in self.listCity)
                {
                    if ([str isEqualToString:location.city])
                    {
                        isExist = TRUE;
                        break;
                    }
                }
                if (!isExist) {
                    [self.listCity addObject:location.city];
                }
            }
            
            
            
        }
        
        if ([self.listReview count] == 0)
        {
            [RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"Currently there exists no place based on your filter parameters!"];
        }
        else
        {
            [self loadGerne];
        }
        
        self.listReviewResult = [NSMutableArray new];
        for(RCLocation *loc in self.listReview)
        {
            [self.listReviewResult addObject:loc];
        }
        
        [self.tbReview reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnGoTouched:(id)sender
{
    NSString *price = nil;
    if ([self.tfPrice.text length] > 0)
    {
        price = self.tfPrice.text;
    }
    
    NSString *type = nil;
    if ([self.tfType.text isEqualToString:@"eat"])
    {
        type = @"eat";
    }
    if ([self.tfType.text isEqualToString:@"stay"])
    {
        type = @"stay";
    }
    if ([self.tfType.text isEqualToString:@"drink"])
    {
        type = @"drink";
    }
    
    NSString *genre = nil;
    if(self.tfGenre.text.length > 0)
    {
        genre = self.tfGenre.text;
    }
    NSString *city = nil;
    if(self.tfCity.text.length > 0)
    {
        city = self.tfCity.text;
    }
    [self.listReviewResult removeAllObjects];
    for(RCLocation *loc in self.listReview)
    {
        if([self isLocationHasThisGenre:genre loc:loc] && [self isLocationHasThisCity:city loc:loc] && [ self isLocationOFType:type loc:loc] && [self isPriceRangeTheSame:price loc:loc])
        {
            [self.listReviewResult addObject:loc];
        }
    }
    
    [self.tbReview reloadData];
   
}

- (IBAction)btnShareTouched:(id)sender
{
    NSMutableArray *listCheck = [[NSMutableArray alloc] init];
    for (RCLocation *location in self.listReviewResult)
    {
        if (location.isMark)
        {
            [listCheck addObject:location];
        }
    }
    
    if ([listCheck count] == 0)
    {
        [RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"You must select places to share!"];
        return;
    }
    
    [RCCommonUtils drawListLocationToPDF:listCheck];
    [self openEmail];
}

- (void)openEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"My recommendations"];
        NSArray *toRecipients = [NSArray arrayWithObjects:nil];
        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = @"";
        [mailer setMessageBody:emailBody isHTML:NO];
        
        NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        NSString* documentDirectory = [documentDirectories objectAtIndex:0];
        NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:@"share.pdf"];
        NSData *pdfData = [NSData dataWithContentsOfFile:documentDirectoryFilename];
        [mailer addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"reccit.pdf"];
        
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)btnDontTouched:(id)sender
{
    [currentTextField resignFirstResponder];
}

#pragma mark -
#pragma mark - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            [RCCommonUtils showMessageWithTitle:@"Success" andContent:@"Your mail sent successfully!"];
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            [RCCommonUtils showMessageWithTitle:@"Failed" andContent:@"Your mail sent failure!"];
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
    self.tfCity.text = @"";
    self.tfGenre.text = @"";
    self.tfPrice.text = @"";
    self.tfType.text = @"";
}

#pragma mark -
#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listReviewResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    RCShareCell *cell = (RCShareCell *)[tableView dequeueReusableCellWithIdentifier:@"RCShareCell"];
    
    RCLocation *review = [self.listReviewResult objectAtIndex:indexPath.row];
    
    [cell.lbName setText:review.name];
    [cell.lbName setTextColor:kRCTextColor];
    
    cell.checkBox.tag = indexPath.row;
    
    if (review.isMark) {
        cell.checkBox.selected = YES;
    } else {
        cell.checkBox.selected = NO;
    }
    
    if (indexPath.row %2 == 0) {
        [cell.contentView setBackgroundColor:kRCTableViewCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    
    if([review.recommendation isEqualToString:@"YES"])
    {
        //((UIImageView *)[cell viewWithTag:3003]).image = [UIImage imageNamed:@"Icon-Like.png"];
        cell.imgLike.hidden = NO;
        cell.imgLike.image = [UIImage imageNamed:@"Icon-Like.png"];
    }
    else
    {
        if([review.recommendation isEqualToString:@"NO"])
        {
            cell.imgLike.hidden = NO;
            //((UIImageView *)[cell viewWithTag:3003]).image = [UIImage imageNamed:@"Icon-Dislike.png"];
             cell.imgLike.image = [UIImage imageNamed:@"Icon-Dislike.png"];

        }
        else
        {
            //((UIImageView *)[cell viewWithTag:3003]).hidden = YES;
            cell.imgLike.hidden = YES;

        }

    }
    
    
    return cell;
}

- (IBAction)btnCheckBoxTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    RCLocation *review = [self.listReviewResult objectAtIndex:btn.tag];
    
    review.isMark = !review.isMark;
    [self.tbReview reloadData];
}

#pragma mark -
#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
    RCLocation *location = [self.listReviewResult objectAtIndex:indexPath.row];
    // TODO
    
    reviewVc = [[RCReviewInDetailsViewController alloc] initWithNibName:@"RCReviewInDetailsViewController" bundle:nil];
    reviewVc.vsParrent = self;
    reviewVc.location = location;
    reviewVc.shouldSendImmediately = YES;
    reviewVc.isDelta = NO;
    //[self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
    
    [self presentSemiModalViewController:reviewVc];
    
    
    //[self performSegueWithIdentifier:@"PushMyReview" sender:location];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        
    }
}

-(IBAction)touchMe:(id)sender
{
    UIImageView *img = (UIImageView *)sender;
    if(img.tag == 101)
    {
        currentTextField = _tfGenre;
        [self.picker reloadAllComponents];
    }
    if(img.tag == 102)
    {
        currentTextField = _tfType;
        [self.picker reloadAllComponents];
    }
    if(img.tag == 103)
    {
        currentTextField = _tfPrice;
        [self.picker reloadAllComponents];
    }
    if(img.tag == 104)
    {
        currentTextField = _tfCity;
        [self.picker reloadAllComponents];
    }
}

- (IBAction)handleMyTap:(id)sender {
    
    NSLog(@"tap here");
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextField = textField;
    self.picker.backgroundColor = [UIColor whiteColor];

    [self.picker reloadAllComponents];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentTextField = nil;
}

#pragma mark -
#pragma mark - Picker delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (currentTextField == self.tfGenre)
    {
        if (row == 0) return @"";
        return [[RCDataHolder getListCountry] objectAtIndex:row-1];
    }
    
    if (currentTextField == self.tfPrice)
    {
        switch (row) {
            case 0:
                return @"";
            case 1:
                return @"$";
            case 2:
                return @"$$";
            case 3:
                return @"$$$";
            case 4:
                return @"$$$$";
            case 5:
                return @"$$$$$";
        }
    }
    
    
    if (currentTextField == self.tfType)
    {
        switch (row) {
            case 0:
                return @"";
            case 1:
                return @"eat";
            case 2:
                return @"drink";
            case 3:
                return @"stay";
        }
    }
    
    if (currentTextField == self.tfCity)
    {
        if (row == 0) return @"";
        return [self.listCity objectAtIndex:row-1];
    }
    
    return nil;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (currentTextField == self.tfGenre)
    {
        return [[RCDataHolder getListCountry] count] + 1;
    }
    
    if (currentTextField == self.tfPrice)
    {
        return 6;
    }
    
    if (currentTextField == self.tfType)
    {
        return 4;
    }
    
    if (currentTextField == self.tfCity)
    {
        return [self.listCity count] + 1;
    }
    
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (currentTextField == self.tfGenre)
    {
        if (row == 0)
            self.tfGenre.text = @"";
        else
            self.tfGenre.text = [[RCDataHolder getListCountry] objectAtIndex:row-1];
    }
    
    if (currentTextField == self.tfPrice)
    {
        switch (row) {
            case 0:
                self.tfPrice.text = @"";
                break;
            case 1:
                self.tfPrice.text = @"$";
                break;
            case 2:
                self.tfPrice.text = @"$$";
                break;
            case 3:
                self.tfPrice.text = @"$$$";
                break;
            case 4:
                self.tfPrice.text = @"$$$$";
                break;
            case 5:
                self.tfPrice.text = @"$$$$$";
                break;
        }
    }
    
    if (currentTextField == self.tfType)
    {



        switch (row) {
            case 0:
                self.tfType.text = @"";
                _tfGenre.hidden = NO;
                _tfBackGenre.hidden = NO;
                break;
            case 1:
                self.tfType.text = @"eat";
                _tfGenre.hidden = NO;
                _tfBackGenre.hidden = NO;
                break;
            case 2:
                self.tfType.text = @"drink";
                //[RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"Current field is available for only type restaurants!"];

                _tfGenre.hidden = YES;
                _tfBackGenre.hidden = YES;
                break;
            case 3:
                //[RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"Current field is available for only type restaurants!"];
                //return;
                _tfGenre.hidden = YES;
                _tfBackGenre.hidden = YES;
                self.tfType.text = @"stay";
        }
    }
    
    if (currentTextField == self.tfCity)
    {
        if (row == 0) self.tfCity.text = @"";
        else 
        self.tfCity.text = [self.listCity objectAtIndex:row-1];
    }
}

- (void)viewDidUnload {
    [self setTfBackGenre:nil];
    [self setTfBackGenre:nil];
    [self setBkgImage:nil];
    [self setBtnShare:nil];
    [super viewDidUnload];
}
@end
