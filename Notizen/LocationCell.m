//
//  LocationCell.m
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "LocationCell.h"
#import "StoreHandler.h"

@implementation LocationCell

- (void)awakeFromNib {
    // Initialization code
    self.noteMapView = [[MKMapView alloc] initWithFrame:CGRectNull];
    [self.noteMapView.layer setMasksToBounds:YES];
    [self.noteMapView.layer setCornerRadius:5];
    [self.noteMapView setUserInteractionEnabled:NO];
    [self.noteMapView setShowsUserLocation:NO];
    //[self.noteMapView setScrollEnabled:YES];
    
//    if ([getDefault(@"showLocation") boolValue]) {
//        [self.noteMapView setShowsUserLocation:YES];
//    }
//    else {
//        [self.noteMapView setShowsUserLocation:NO];
//    }
    
    myManager = [[CLLocationManager alloc] init];
    [myManager requestWhenInUseAuthorization];
}

- (void)showLocationInMaps {
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:myCoordinate addressDictionary:nil]];
    [item openInMapsWithLaunchOptions:nil];
}

- (void)addAnnotationForCoordinate:(CLLocationCoordinate2D)coordinate {
    [self removeAllPinsButUserLocation2];
    
    myCoordinate = coordinate;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [annotation setTitle:@"Notiz"]; //You can set the subtitle too
    [self.noteMapView addAnnotation:annotation];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    region.span = span;
    region.center = coordinate;
    
    [self.noteMapView setRegion:region animated:NO];
    [self.noteMapView regionThatFits:region];
    
    [self.noteMapView selectAnnotation:annotation animated:NO];
}

- (void)removeAllPinsButUserLocation2
{
    id userLocation = [self.noteMapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.noteMapView annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    [self.noteMapView removeAnnotations:pins];
    pins = nil;
}

- (void)layoutSubviews {
    if (![self.subviews containsObject:self.noteMapView]) [self addSubview:self.noteMapView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
