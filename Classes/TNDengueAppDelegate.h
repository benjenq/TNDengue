//
//  TNDengueAppDelegate.h
//  TNDengue
//
//  Created by benejnq on 15/9/15.
//  Copyright 2015 benejnq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNDengueAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

