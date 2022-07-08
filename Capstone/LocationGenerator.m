//
//  LocationGenerator.m
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import "LocationGenerator.h"

@implementation LocationGenerator

+(NSArray<GMSMarker *> *)generateMarkersNear:(CLLocationCoordinate2D)location count:(int)count {
  NSMutableArray *markerArray = [[NSMutableArray alloc] init];
  for (int index = 1; index <= count; ++index) {
    const double extent = 0.1;
    double lat = location.latitude + extent * [self randomScale];
    double lng = location.longitude + extent * [self randomScale];
    CLLocationCoordinate2D randomLocation = CLLocationCoordinate2DMake(lat, lng);
    GMSMarker *marker = [GMSMarker markerWithPosition:randomLocation];
    marker.icon = [UIImage imageNamed:@"custom_pin.png"];
    [markerArray addObject:marker];
  }
  return markerArray;
}

// Returns a random value between -1.0 and 1.0.
+ (double)randomScale {
  return (double)arc4random() / UINT32_MAX * 2.0 - 1.0;
}

@end
