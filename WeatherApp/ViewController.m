//
//  ViewController.m
//  WeatherApp
//
//  Created by Ruining Sun on 8/15/13.
//  Copyright (c) 2013 Ruining Sun. All rights reserved.
//

#import "ViewController.h"
#import "WeatherAPI.h"
#import "HomeViewController.h"

@interface ViewController () {
    WeatherAPI *_weatherAPI;
    NSArray *_forecast;
    NSDateFormatter *_dateFormatter;
    int downloadCount;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    downloadCount = 0;
    NSString *dateComponents = @"H:m yyMMMMd";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale] ];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:dateFormat];
    _forecast = @[];
    _weatherAPI = [[WeatherAPI alloc] initWithAPIKey:@"1111111111"]; 
    [_weatherAPI setLangWithPreferedLanguage];
    [_weatherAPI setTemperatureFormat:kOWMTempFahrenheit];
    [self.activityIndicator startAnimating];
    [_weatherAPI currentWeatherByCityName:cityname withCallback:^(NSError *error, NSDictionary *result) {
        downloadCount++;
        if (downloadCount > 1) [self.activityIndicator stopAnimating];
        if (error) {
            return;
        }
        self.cityName.text = [NSString stringWithFormat:@"%@, %@",
                              result[@"name"],
                              result[@"sys"][@"country"]
                              ];
        self.currentTemp.text = [NSString stringWithFormat:@"%.1f℉",
                                 [result[@"main"][@"temp"] floatValue] ];
        
        self.currentTimestamp.text =  [_dateFormatter stringFromDate:result[@"dt"]];
        
        self.weather.text = result[@"weather"][0][@"description"];
    }];
    [_weatherAPI forecastWeatherByCityName:cityname withCallback:^(NSError *error, NSDictionary *result) {
        downloadCount++;
        if (downloadCount > 1) [self.activityIndicator stopAnimating];
        
        if (error) {
            return;
        }
        _forecast = result[@"list"];
        [self.forecastTableView reloadData];
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _forecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *forecastData = [_forecast objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%.1f℉ - %@",
                           [forecastData[@"main"][@"temp"] floatValue],
                           forecastData[@"weather"][0][@"main"]
                           ];
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:forecastData[@"dt"]];
    return cell;
    
}

@end
