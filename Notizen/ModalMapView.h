//
//  ModalMapView.h
//  Notizen
//
//  Created by Johannes Körner on 12.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ModalMapView : UIView {
    CGRect startingFrame;
    CLLocationCoordinate2D coordinate;
}

@property (strong) MKMapView *mapView;
@property (strong) UIView *dimView;
@property (nonatomic) CGFloat offset;

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;
- (void)showFromFrame:(CGRect)aMapViewFrame onTopOfView:(UIView *)aView;
- (void)dismiss;

@end
