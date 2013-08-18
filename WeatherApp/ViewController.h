//
//  ViewController.h
//  WeatherApp
//
//  Created by Ruining Sun on 8/15/13.
//  Copyright (c) 2013 Ruining Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface ViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *cityName;
@property (strong, nonatomic) IBOutlet UILabel *currentTemp;
@property (strong, nonatomic) IBOutlet UITableView *forecastTableView;
@property (strong, nonatomic) IBOutlet UILabel *currentTimestamp;
@property (strong, nonatomic) IBOutlet UILabel *weather;

@end
