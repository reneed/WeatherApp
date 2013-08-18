//
//  CoordinateViewController.h
//  WeatherApp
//
//  Created by Ruining Sun on 8/16/13.
//  Copyright (c) 2013 Ruining Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WeatherAPI.h"

@interface CoordinateViewController : UIViewController<CLLocationManagerDelegate>
{
    CLLocationManager *locManager;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UILabel *lonLabel;
@property (retain, nonatomic) IBOutlet UILabel *latLabel;
@property (retain, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) IBOutlet UILabel *cityName;
@property (strong, nonatomic) IBOutlet UILabel *currentTemp;
@property (strong, nonatomic) IBOutlet UITableView *forecastTableView;
@property (strong, nonatomic) IBOutlet UILabel *weather;


@end