//
//  AppDelegate.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "AppDelegate.h"
#import <XZML/XZMLCore.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [XZMLParser setFontName:@"ChalkboardSE-Regular" forAbbreviation:@"D"];
    [XZMLParser setFontName:@"ChalkboardSE-Bold" forAbbreviation:@"B"];
    
    [XZMLParser setFontName:@"PingFangSC-Light" forAbbreviation:@"L"];
    [XZMLParser setFontName:@"PingFangSC-Regular" forAbbreviation:@"T"];
    [XZMLParser setFontName:@"PingFangSC-Medium" forAbbreviation:@"M"];
    [XZMLParser setFontName:@"PingFangSC-Semibold" forAbbreviation:@"S"];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0)) {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions API_AVAILABLE(ios(13.0)) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
