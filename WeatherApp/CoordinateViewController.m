//
//  CoordinateViewController.m
//  WeatherApp
//
//  Created by Ruining Sun on 8/16/13.
//  Copyright (c) 2013 Ruining Sun. All rights reserved.
//

#import "CoordinateViewController.h"

@interface CoordinateViewController (){

    WeatherAPI *_weatherAPI;
    NSArray *_forecast;
    NSDateFormatter *_dateFormatter;
    
    int downloadCount;
}


@end

@implementation CoordinateViewController
@synthesize lonLabel;
@synthesize latLabel;
@synthesize locManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化位置管理器
    locManager = [[CLLocationManager alloc]init];
    //设置代理
    locManager.delegate = self;
    //设置位置经度
    locManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置每隔100米更新位置
    locManager.distanceFilter = 100;
    //开始定位服务
    [locManager startUpdatingLocation];
    
    [super viewDidLoad];
    

    
    
    

    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//协议中的方法，作用是每当位置发生更新时会调用的委托方法
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //结构体，存储位置坐标
    CLLocationCoordinate2D loc = [newLocation coordinate];
    float longitude = loc.longitude;
    float latitude = loc.latitude;
    self.lonLabel.text = [NSString stringWithFormat:@"%f",longitude];
    self.latLabel.text = [NSString stringWithFormat:@"%f",latitude];
    
    downloadCount = 0;
    
    _forecast = @[];
    
    _weatherAPI = [[WeatherAPI alloc] initWithAPIKey:@"1111111111"]; // Replace the key with your own
    
    // We want localized strings according to the prefered system language
    [_weatherAPI setLangWithPreferedLanguage];
    
    // We want the temperatures in celcius, you can also get them in farenheit.
    [_weatherAPI setTemperatureFormat:kOWMTempFahrenheit];
    
    [self.activityIndicator startAnimating];
    [_weatherAPI currentWeatherByCoordinate:loc withCallback:^(NSError *error, NSDictionary *result) {
        downloadCount++;
        if (downloadCount > 1) [self.activityIndicator stopAnimating];
        
        if (error) {
            // Handle the error
            return;
        }
        
        self.cityName.text = [NSString stringWithFormat:@"%@, %@",
                              result[@"name"],
                              result[@"sys"][@"country"]
                              ];
        
        self.currentTemp.text = [NSString stringWithFormat:@"%.1f℉",
                                 [result[@"main"][@"temp"] floatValue] ];
        
        self.weather.text = result[@"weather"][0][@"description"];
    }];
    
    [_weatherAPI forecastWeatherByCoordinate: loc withCallback:^(NSError *error, NSDictionary *result) {
        downloadCount++;
        if (downloadCount > 1) [self.activityIndicator stopAnimating];
        
        if (error) {
            // Handle the error;
            return;
        }
        
        _forecast = result[@"list"];
        [self.forecastTableView reloadData];
        
    }];
    
}

//当位置获取或更新失败会调用的方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorMsg = nil;
    if ([error code] == kCLErrorDenied) {
        errorMsg = @"访问被拒绝";
    }
    if ([error code] == kCLErrorLocationUnknown) {
        errorMsg = @"获取位置信息失败";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Location"
                                                       message:errorMsg delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil];
    [alertView show];

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