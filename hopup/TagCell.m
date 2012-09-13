//
//  TagCell.m
//  hopup
//
//  Created by Edward Kim on 9/10/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Tag.h"
#import "TagCell.h"
#import "TopicsStore.h"

@interface TagCell ()
@property (strong) UILabel *nameLabel;
@property (strong) UILabel *locationLabel;
@property (strong) UILabel *topicLabel;
@property (strong) MKMapView *mapView;
@end

@implementation TagCell
@synthesize cellTag = _cellTag;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundCell.png"]];
        
        [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, 100.0)];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        CGRect nameLabelFrame = CGRectMake(6.0, 6.0, 190.0, 42.0);
        CGRect locationLabelFrame = CGRectMake(20.0, 42.0, 176.0, 34.0);
        CGRect topicLabelFrame = CGRectMake(20.0, 76.0, 176.0, 17.0);
        CGRect mapViewFrame = CGRectMake(206.0, 6.0, 108.0, 88.0);
        
        self.nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
        self.locationLabel = [[UILabel alloc] initWithFrame:locationLabelFrame];
        self.topicLabel = [[UILabel alloc] initWithFrame:topicLabelFrame];
        self.mapView = [[MKMapView alloc] initWithFrame:mapViewFrame];
        
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.locationLabel.backgroundColor = [UIColor clearColor];
        self.topicLabel.backgroundColor = [UIColor clearColor];
        self.mapView.backgroundColor = [UIColor clearColor];
        
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
        self.nameLabel.textColor = [UIColor brownColor];
        self.locationLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        self.locationLabel.textColor = [UIColor brownColor];
        self.locationLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.locationLabel.numberOfLines = 2;
        self.topicLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        self.topicLabel.textColor = [UIColor brownColor];
        
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.locationLabel];
        [self.contentView addSubview:self.topicLabel];
        [self.contentView addSubview:self.mapView];
    }
    return self;
}

- (id)init {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (Tag*)cellTag {
    if (!_cellTag) {
        _cellTag = [Tag new];
    }
    return _cellTag;
}

- (void)setCellTag:(Tag *)cellTag {
    _cellTag = cellTag;
    self.nameLabel.text = self.cellTag.text;
    self.locationLabel.text = self.cellTag.location;
    Topic *topic = [[[TopicsStore sharedStore] topicsByTopicId] objectForKey:@(self.cellTag.topicId)];
    self.topicLabel.text = topic.name;
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.cellTag.lat, self.cellTag.lng);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 500.0, 500.0);
    [self.mapView setRegion:region];
    
    MKPointAnnotation *point = [MKPointAnnotation new];
    point.coordinate = coord;
    [self.mapView addAnnotation:point];
    
}

@end
