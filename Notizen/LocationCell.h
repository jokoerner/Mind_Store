//
//  LocationCell.h
//  Notizen
//
//  Created by Johannes Körner on 04.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationCell : UITableViewCell {
    CLLocationCoordinate2D myCoordinate;
    CLLocationManager *myManager;
}

@property (strong) MKMapView *noteMapView;
@property (nonatomic) BOOL muchEditing;

- (void)addAnnotationForCoordinate:(CLLocationCoordinate2D)coordinate;
    
@end
