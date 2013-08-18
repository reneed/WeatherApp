//
//  WeatherAPI.h
//  WeatherApp
//
//  Created by Ruining Sun on 8/15/13.
//  Copyright (c) 2013 Ruining Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    kOWMTempKelvin,
    kOWMTempCelcius,
    kOWMTempFahrenheit
} OWMTemperature;


@interface WeatherAPI : NSObject

- (instancetype) initWithAPIKey:(NSString *) apiKey;

- (void) setApiVersion:(NSString *) version;
- (NSString *) apiVersion;

- (void) setTemperatureFormat:(OWMTemperature) tempFormat;
- (OWMTemperature) temperatureFormat;

- (void) setLangWithPreferedLanguage;
- (void) setLang:(NSString *) lang;
- (NSString *) lang;
-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;


-(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                      withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;


-(void) forecastWeatherByCityName:(NSString *) name
                     withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) forecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                       withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;


-(void) dailyForecastWeatherByCityName:(NSString *) name
                             withCount:(int) count
                           andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

-(void) dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                               withCount:(int) count
                             andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;



@end