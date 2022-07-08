//
//  LocationGenerator.h
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface LocationGenerator : NSObject
+ (NSArray<GMSMarker *> *) generateMarkersNear:(CLLocationCoordinate2D)location count:(int)count;
@end

NS_ASSUME_NONNULL_END
