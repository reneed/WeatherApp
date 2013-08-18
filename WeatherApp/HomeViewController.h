//
//  HomeViewController.h
//  WeatherApp
//
//  Created by Ruining Sun on 8/15/13.
//  Copyright (c) 2013 Ruining Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
extern NSString *cityname;
@interface HomeViewController : UIViewController
//@property (strong, nonatomic)NSString *cityname;
@property IBOutlet UITextField *setName;
-(IBAction)setCityname;
@end
