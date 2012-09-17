//
//  NewTagViewController.m
//  hopup
//
//  Created by Edward Kim on 9/14/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "FormPickerCell.h"
#import "FormTextCell.h"
#import <MapKit/MapKit.h>
#import "NewTagViewController.h"
#import "SessionStore.h"
#import "TagsStore.h"
#import "TopicsStore.h"

@interface NewTagViewController () <UITableViewDataSource,UITableViewDelegate>
@property (strong) UITableView *tableView;
@property (strong) MKMapView *mapView;
@property (strong) UILabel *errorLabel;
@property (strong) NSArray *formCells;
@property (strong) CLGeocoder *geocoder;
@property (strong) FormTextCell *nameCell;
@property (strong) FormTextCell *locationCell;
@property (strong) FormPickerCell *topicCell;
@end

@implementation NewTagViewController
@synthesize completionBlock;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __weak NewTagViewController *weakSelf = self;
        
        self.nameCell = [FormTextCell new];
        self.nameCell.textLabel.text = @"Name";
        self.nameCell.input.placeholder = @"Tag Name";
        
        self.locationCell = [FormTextCell new];
        self.locationCell.textLabel.text = @"Location";
        self.locationCell.input.placeholder = @"715 Bryant St.";
        self.locationCell.onDidCompleteEditing = ^(FormTextCell *cell) {
            [weakSelf formTextCellDidFinishEditing:cell];
        };

        self.topicCell = [FormPickerCell new];
        self.topicCell.textLabel.text = @"Topic";
        
        self.formCells = [NSArray arrayWithObjects:self.nameCell,self.locationCell,self.topicCell, nil];
        self.completionBlock = ^{};
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)loadView {
    Topic *topic = [[[TopicsStore sharedStore] topicsByTopicId] objectForKey:@(self.topicId)];
    self.topicCell.pickerText = topic.name;
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    CGSize mainViewSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height-20.0);
    
    CGRect tableViewRect = CGRectMake(0.0, 55.0, mainViewSize.width, mainViewSize.height/3.0);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGRect bottomHalfScreen = CGRectMake(0.0, mainViewSize.height/2.0, mainViewSize.width, mainViewSize.height/2.0);
    CGRect mapViewRect = CGRectInset(bottomHalfScreen, 5.0, 5.0);
    self.mapView = [[MKMapView alloc] initWithFrame:mapViewRect];
    [self.mapView setShowsUserLocation:YES];
    
    CGRect toolbarFrame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0);
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGFloat yPos = tableViewRect.origin.y + tableViewRect.size.height;
    submitButton.frame = CGRectMake(mainViewSize.width/4.0, yPos-4.0, mainViewSize.width/2.0, 25.0);
    [submitButton addTarget:self action:@selector(submitTag:) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAddTag:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *currLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect currLocationButtonFrame = CGRectMake(0.0, 0.0, 25.0, 25.0);
    [currLocationButton addTarget:self action:@selector(populateCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    currLocationButton.frame = currLocationButtonFrame;
    [currLocationButton setBackgroundImage:[UIImage imageNamed:@"nav_icon.png"] forState:UIControlStateNormal];
    [toolbar setItems:[NSArray arrayWithObjects:cancelButton, spacer, [[UIBarButtonItem alloc] initWithCustomView:currLocationButton], nil]];
    
    CGRect errorFrame = CGRectMake(0.0, 44.0, mainViewSize.width, 20.0);
    self.errorLabel = [[UILabel alloc] initWithFrame:errorFrame];
    self.errorLabel.textColor = [UIColor redColor];
    self.errorLabel.textAlignment = UITextAlignmentCenter;
    [self.errorLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:toolbar];
    [self.view addSubview:self.errorLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:submitButton];
    [self.view addSubview:self.mapView];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark helper methods

- (void)cancelAddTag:(UIBarButtonItem*)button {
    self.completionBlock();
}

- (void)showError:(NSString*)error {
    self.errorLabel.text = error;
}

- (void)submitTag:(UIButton*)button {
    if (!self.nameCell.input.text || !self.locationCell.input.text || !self.topicCell.pickerText) {
        [self showError:@"Please enter all fields"];
        return;
    }
    
    NSArray *myTopics = [[TopicsStore sharedStore] topicsWithUserId:[[[SessionStore sharedStore] currentUser] userId]];
    Topic *topicForTag = nil;
    for (Topic *topic in myTopics) {
        if ([topic.name.lowercaseString isEqualToString:self.topicCell.input.titleLabel.text.lowercaseString]) {
            topicForTag = topic;
            break;
        }
    }
    
    if (!topicForTag) {
        [self showError:@"Invalid topic"];
        return;
    }
    
    Tag *newTag = [Tag new];
    newTag.text = self.nameCell.input.text;
    newTag.location = self.locationCell.input.text;
    newTag.topicId = topicForTag.topicId;
    
    [[TagsStore sharedStore] createTagWithTag:newTag withBlock:^(BOOL successful) {
        if (successful) {
            self.completionBlock();
        } else {
            [self showError:@"Tag creation was unsuccessful"];
        }
    }];
}

- (void)populateCurrentLocation {
    CLLocation *curr = [[self.mapView userLocation] location];
    [self.geocoder reverseGeocodeLocation:curr completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placeMark = [placemarks objectAtIndex:0];
            self.locationCell.input.text = ABCreateStringWithAddressDictionary(placeMark.addressDictionary, NO);
            
            CLLocationCoordinate2D coord = [placeMark.location coordinate];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 500.0, 500.0);
            [self.mapView setRegion:region];
            
            MKPointAnnotation *point = [MKPointAnnotation new];
            point.coordinate = coord;
            [self.mapView addAnnotation:point];
        }
    }];

}

#pragma mark UITableViewDelegate methods

#pragma mark UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.formCells objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.formCells count];
}

- (void)formTextCellDidFinishEditing:(FormTextCell*)cell {
    if ([cell.textLabel.text isEqual:@"Location"] && [cell.input.text length] > 0) {
        [self.geocoder geocodeAddressString:cell.input.text completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks count] > 0) {
                CLPlacemark *placeMark = [placemarks objectAtIndex:0];
                
                cell.input.text = ABCreateStringWithAddressDictionary(placeMark.addressDictionary, NO);
                
                CLLocationCoordinate2D coord = [placeMark.location coordinate];
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 500.0, 500.0);
                [self.mapView setRegion:region];
                
                MKPointAnnotation *point = [MKPointAnnotation new];
                point.coordinate = coord;
                [self.mapView addAnnotation:point];
            }
        }];
    }
}


@end
