//
//  RCShareViewController.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import <MessageUI/MessageUI.h>

@interface RCShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UITextField *currentTextField;
}
@property (weak, nonatomic) IBOutlet UIImageView *tfBackGenre;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UITableView *tbReview;

@property (weak, nonatomic) IBOutlet UITextField *tfPrice;
@property (weak, nonatomic) IBOutlet UITextField *tfType;
@property (weak, nonatomic) IBOutlet UITextField *tfGenre;
@property (weak, nonatomic) IBOutlet UITextField *tfCity;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbarDone;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@property (strong, nonatomic) NSMutableArray *listReview;
@property (strong, nonatomic) NSMutableArray *listReviewResult;

@property (strong, nonatomic) NSMutableArray *listCity;
@property (strong, nonatomic) ASIHTTPRequest *request;

- (IBAction)handleTap:(UITapGestureRecognizer *)sender;
@end
