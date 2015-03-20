//
//  ShowLocations.m
//  Notizen
//
//  Created by Johannes Körner on 18.03.15.
//  Copyright (c) 2015 Johannes Körner. All rights reserved.
//

#import "ShowLocations.h"


@interface ShowLocations()

@end


@implementation ShowLocations

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    [WKInterfaceController openParentApplication:@{@"action" : @"showLocations"} reply:^(NSDictionary *replyInfo, NSError *error) {
        //Auf Karte anzeigen
        NSArray *dataLocations = [replyInfo valueForKey:@"locations"];
        NSData *currentLocationData = [replyInfo valueForKey:@"currentLocation"];
        CLLocationCoordinate2D currentCoordinate;
        [currentLocationData getBytes:&currentCoordinate length:sizeof(currentCoordinate)];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentCoordinate, 1000, 1000);
        [self.map setRegion:region];
        
        [self.map addAnnotation:currentCoordinate withPinColor:WKInterfaceMapPinColorRed];
        
        for (int i = 0; i < dataLocations.count; i++) {
            NSData *someData = [dataLocations objectAtIndex:i];
            CLLocationCoordinate2D someCoordinate;
            [someData getBytes:&someCoordinate length:sizeof(someCoordinate)];
            [self.map addAnnotation:someCoordinate withPinColor:WKInterfaceMapPinColorGreen];
        }
        
        //MKCoordinateRegion region = [self regionForAnnotations:dataLocations current:currentCoordinate];
        
    }];
}


- (MKCoordinateRegion) regionForAnnotations:(NSArray*) annotations current:(CLLocationCoordinate2D)coord
{
    double minLat=90.0f, maxLat=-90.0f;
    double minLon=180.0f, maxLon=-180.0f;
    
    for (NSData *mka in annotations) {
        CLLocationCoordinate2D coordinate;
        [mka getBytes:&coordinate length:sizeof(coordinate)];
        if ( coordinate.latitude  < minLat ) minLat = coordinate.latitude;
        if ( coordinate.latitude  > maxLat ) maxLat = coordinate.latitude;
        if ( coordinate.longitude < minLon ) minLon = coordinate.longitude;
        if ( coordinate.longitude > maxLon ) maxLon = coordinate.longitude;
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat+maxLat)/2.0, (minLon+maxLon)/2.0);
    MKCoordinateSpan span = MKCoordinateSpanMake(maxLat-minLat, maxLon-minLon);
    MKCoordinateRegion region = MKCoordinateRegionMake (center, span);
    
    MKMapPoint newCenterPoint = MKMapPointForCoordinate(coord);
    
    [self.map setVisibleMapRect:MKMapRectMake(newCenterPoint.x, newCenterPoint.y, span.latitudeDelta, span.longitudeDelta)];
    
    return region;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



