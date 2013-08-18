//
//  WeatherAPI.m
//  WeatherApp
//
//  Created by Ruining Sun on 8/15/13.
//  Copyright (c) 2013 Ruining Sun. All rights reserved.
//

#import "WeatherAPI.h"
#import "AFJSONRequestOperation.h"

@interface WeatherAPI () {
    NSString *_baseURL;
    NSString *_apiKey;
    NSString *_apiVersion;
    NSOperationQueue *_weatherQueue;
    
    NSString *_lang;
    
    OWMTemperature _currentTemperatureFormat;
}

@end

@implementation WeatherAPI

- (instancetype) initWithAPIKey:(NSString *) apiKey {
    self = [super init];
    if (self) {
        _baseURL = @"http://api.openweathermap.org/data/";
        _apiKey  = apiKey;
        _apiVersion = @"2.5";
        
        _weatherQueue = [[NSOperationQueue alloc] init];
        _weatherQueue.name = @"OMWWeatherQueue";
        
        _currentTemperatureFormat = kOWMTempFahrenheit;
        
    }
    return self;
}


- (void) setTemperatureFormat:(OWMTemperature) tempFormat {
    _currentTemperatureFormat = tempFormat;
}
- (OWMTemperature) temperatureFormat {
    return _currentTemperatureFormat;
}

+ (NSNumber *) tempToCelcius:(NSNumber *) tempKelvin
{
    return @(tempKelvin.floatValue - 273.15);
}

+ (NSNumber *) tempToFahrenheit:(NSNumber *) tempKelvin
{
    return @((tempKelvin.floatValue * 9/5) - 459.67);
}


- (NSNumber *) convertTemp:(NSNumber *) temp {
    if (_currentTemperatureFormat == kOWMTempCelcius) {
        return [WeatherAPI tempToCelcius:temp];
    } else if (_currentTemperatureFormat == kOWMTempFahrenheit) {
        return [WeatherAPI tempToFahrenheit:temp];
    } else {
        return temp;
    }
}

- (NSDate *) convertToDate:(NSNumber *) num {
    return [NSDate dateWithTimeIntervalSince1970:num.intValue];
}

- (NSDictionary *) convertResult:(NSDictionary *) res {
    
    NSMutableDictionary *dic = [res mutableCopy];
    NSMutableDictionary *main = [[dic objectForKey:@"main"] mutableCopy];
    if (main) {
        main[@"temp"] = [self convertTemp:main[@"temp"]];
        main[@"temp_min"] = [self convertTemp:main[@"temp_min"]];
        main[@"temp_max"] = [self convertTemp:main[@"temp_max"]];
        dic[@"main"] = [main copy];
        
    }
    
    NSMutableDictionary *temp = [[dic objectForKey:@"temp"] mutableCopy];
    if (temp) {
        temp[@"day"] = [self convertTemp:temp[@"day"]];
        temp[@"eve"] = [self convertTemp:temp[@"eve"]];
        temp[@"max"] = [self convertTemp:temp[@"max"]];
        temp[@"min"] = [self convertTemp:temp[@"min"]];
        temp[@"morn"] = [self convertTemp:temp[@"morn"]];
        temp[@"night"] = [self convertTemp:temp[@"night"]];
        dic[@"temp"] = [temp copy];
    }
    
    
    NSMutableDictionary *sys = [[dic objectForKey:@"sys"] mutableCopy];
    if (sys) {
        
        sys[@"sunrise"] = [self convertToDate: sys[@"sunrise"]];
        sys[@"sunset"] = [self convertToDate: sys[@"sunset"]];
        dic[@"sys"] = [sys copy];
    }
    
    
    NSMutableArray *list = [[dic objectForKey:@"list"] mutableCopy];
    if (list) {
        
        for (int i = 0; i < list.count; i++) {
            [list replaceObjectAtIndex:i withObject:[self convertResult: list[i]]];
        }
        
        dic[@"list"] = [list copy];
    }
    
    dic[@"dt"] = [self convertToDate:dic[@"dt"]];
    
    return [dic copy];
}


- (void) callMethod:(NSString *) method withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    NSOperationQueue *callerQueue = [NSOperationQueue currentQueue];
    NSString *langString;
    if (_lang && _lang.length > 0) {
        langString = [NSString stringWithFormat:@"&lang=%@", _lang];
    } else {
        langString = @"";
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&APPID=%@%@", _baseURL, _apiVersion, method, _apiKey, langString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
         
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        NSDictionary *res = [self convertResult:JSON];
        [callerQueue addOperationWithBlock:^{
            callback(nil, res);
        }];
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        [callerQueue addOperationWithBlock:^{
            callback(error, nil);
        }];
        
    }];
    [_weatherQueue addOperation:operation];
        
}

- (void) setApiVersion:(NSString *) version {
    _apiVersion = version;
}

- (NSString *) apiVersion {
    return _apiVersion;
}

- (void) setLangWithPreferedLanguage {
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *langCodes = @{
                                @"sv" : @"se",
                                @"es" : @"sp",
                                @"en-GB": @"en",
                                @"uk" : @"ua",
                                @"pt-PT" : @"pt",
                                @"zh-Hans" : @"zh_cn",
                                @"zh-Hant" : @"zh_tw",
                                };
    
    NSString *l = [langCodes objectForKey:lang];
    if (l) {
        lang = l;
    }
    
    [self setLang:lang];
}

- (void) setLang:(NSString *) lang {
    _lang = lang;
}

- (NSString *) lang {
    return _lang;
}

#pragma mark current weather

-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{

    
    NSString *method = [NSString stringWithFormat:@"/weather?q=%@", name];
    [self callMethod:method withCallback:callback];
    
}

-(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                      withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
  
    NSString *method = [NSString stringWithFormat:@"/weather?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method withCallback:callback];
       
}


#pragma mark forcast

-(void) forecastWeatherByCityName:(NSString *) name
                     withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast?q=%@", name];
    [self callMethod:method withCallback:callback];
    
}

-(void) forecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                       withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast?lat=%f&lon=%f",
                        coordinate.latitude, coordinate.longitude ];
    [self callMethod:method withCallback:callback];
    
}


#pragma mark forcast - n days

-(void) dailyForecastWeatherByCityName:(NSString *) name
                             withCount:(int) count
                           andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?q=%@&cnt=%d", name, count];
    [self callMethod:method withCallback:callback];
    
}

-(void) dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                               withCount:(int) count
                             andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?lat=%f&lon=%f&cnt=%d",
                        coordinate.latitude, coordinate.longitude, count ];
    [self callMethod:method withCallback:callback];
      
}



@end
