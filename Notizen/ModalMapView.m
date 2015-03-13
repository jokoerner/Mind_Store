//
//  ModalMapView.m
//  Notizen
//
//  Created by Johannes Körner on 12.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ModalMapView.h"
#import "StoreHandler.h"

@implementation ModalMapView

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate {
    if (self = [super init]) {
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectNull];
        self.dimView = [[UIView alloc] initWithFrame:CGRectNull];
        [self.dimView setBackgroundColor:[UIColor blackColor]];
        [self.mapView.layer setOpacity:0.0];
        [self.dimView.layer setOpacity:0.0];
        [self.mapView setShowsUserLocation:YES];
        coordinate = aCoordinate;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(askToShowLocation)];
        [self.mapView addGestureRecognizer:tap];
    }
    return self;
}

- (void)askToShowLocation {
    post(@"openLocationInMaps");
}

- (void)showFromFrame:(CGRect)aMapViewFrame onTopOfView:(UIView *)aView {
    [self setFrame:CGRectMake(0, self.offset, aView.frame.size.width, aView.frame.size.height)];
    [aView addSubview:self];
    
    startingFrame = aMapViewFrame;
    
    [self.mapView setFrame:aMapViewFrame];
    
    [self.dimView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.dimView setBackgroundColor:[UIColor blackColor]];
    [self.dimView.layer setOpacity:0.0];
    
    [self addSubview:self.dimView];
    [self addSubview:self.mapView];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.dimView.layer setOpacity:0.8];
        [self.mapView.layer setOpacity:1.0];
        [self.mapView setFrame:CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.height-64-10)];
    } completion:^(BOOL finished) {
        [self addAnnotation];
    }];
}

- (void)showLocationInMaps {
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    [item openInMapsWithLaunchOptions:nil];
}

- (void)addAnnotation {
    [self removeAllPinsButUserLocation2];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [annotation setTitle:@"Notiz"]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    region.span = span;
    region.center = coordinate;

    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (void)removeAllPinsButUserLocation2
{
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    [self.mapView removeAnnotations:pins];
    pins = nil;
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        [self.mapView setFrame:startingFrame];
        [self.mapView.layer setOpacity:0.0];
        [self.dimView.layer setOpacity:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
