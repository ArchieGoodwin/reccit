//
//  RCSearchViewController.h
//  Reccit
//
//  Created by Lee Way on 1/29/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RCSearchViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *btnIncrease;
@property (weak, nonatomic) IBOutlet UIButton *btnReduce;

@property (weak, nonatomic) IBOutlet UITextField *tfLocation;
@property (weak, nonatomic) IBOutlet UITextField *tfPrice;
@property (weak, nonatomic) IBOutlet UITextField *tfGenre;
@property (weak, nonatomic) IBOutlet UIImageView *bgGenre;
@property (weak, nonatomic) IBOutlet UIImageView *bgSearchGenre;

@property (weak, nonatomic) IBOutlet UIView *viewContent;

@property (weak, nonatomic) IBOutlet UIProgressView *progressDistance;

@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UISlider *sliderDistance;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIButton *btnGo;
@property (weak, nonatomic) IBOutlet UIButton *btnSuprise;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (strong, nonatomic) NSMutableArray *listLocation;
@property (strong, nonatomic) NSMutableArray *listAnnotation;

@property (strong, nonatomic) NSString *categoryName;

@end
