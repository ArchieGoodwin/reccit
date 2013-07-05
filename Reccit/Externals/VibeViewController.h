//
//  ViewController.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "RCLocation.h"
#import "GAITrackedViewController.h"

@class RCConversation;
@interface VibeViewController : GAITrackedViewController <UIBubbleTableViewDataSource>
{
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    IBOutlet UITextField *textField;
    
    NSMutableArray *bubbleData;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *placeTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *bar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBack;

@property (nonatomic, strong) RCLocation *location;
@property (nonatomic, strong) RCConversation *convsersation;
@property (nonatomic, weak) IBOutlet UINavigationItem *lblPlaceName;
@end
