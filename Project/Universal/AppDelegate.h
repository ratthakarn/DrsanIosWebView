//
//  AppDelegate.h
//
//  Copyright (c) 2018 Sherdle. All rights reserved.
//
//  INFO: In this file you can edit some of your apps main properties, like API keys
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "RearTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <OneSignal/OneSignal.h>
#import "CJPAdMobHelper.h"

//START OF CONFIGURATION

#define CONFIG @"config"

/**
 * Layout options
 */
#define APP_THEME_LIGHT NO
#define APP_THEME_COLOR [UIColor colorWithRed:255.0f/255.0f green:87.0f/255.0f blue:34.0f/255.0f alpha:1.0]
#define APP_BAR_SHADOW NO

#define GRADIENT_ONE [UIColor colorWithRed:0.00 green:0.00 blue:1.00 alpha:1.0]
#define GRADIENT_TWO [UIColor colorWithRed:0.29 green:0.53 blue:0.91 alpha:1.0]
#define APP_DRAWER_HEADER NO
#define MENU_TEXT_COLOR [UIColor whiteColor]
#define MENU_TEXT_COLOR_SECTION  [UIColor lightTextColor]

/**
 * About / Texts
 **/
#define NO_CONNECTION_TEXT @"We weren't able to connect to the server. Make sure you have a working internet connection."
#define ABOUT_TEXT @"Thank you for downloading our app! \n\nIf you need any help, press the button below to visit our support."
#define ABOUT_URL @"https://gkrgroup.co.th"
//Clearing both your About Text and About URL will hide the about button

/**
 * Monetization
 **/
#define INTERSTITIAL_INTERVAL 5
#define ADMOB_INTERSTITIAL_ID @""
#define BANNER_ADS_ON false
#define ADMOB_UNIT_ID @""
#define ADMOB_APP_ID @""

#define IN_APP_PRODUCT @""

/**
 * API Keys
 **/
#define ONESIGNAL_APP_ID @""

#define MAPS_API_KEY @""

#define YOUTUBE_CONTENT_KEY @""

#define TWITTER_API @""
#define TWITTER_API_SECRET @""
#define TWITTER_TOKEN @""
#define TWITTER_TOKEN_SECRET @""

#define INSTAGRAM_ACCESS_TOKEN @""
#define FACEBOOK_ACCESS_TOKEN @""
#define PINTEREST_ACCESS_TOKEN @""

#define SOUNDCLOUD_CLIENT @""

#define FLICKR_API @""
#define TUMBLR_API @""


/**
 * WooCommerce
 **/

#define WOOCOMMERCE_HOST @""
#define WOOCOMMERCE_KEY @""
#define WOOCOMMERCE_SECRET @""

/**
 * Other
 */
#define OPEN_IN_BROWSER false
#define WEBVIEW_HIDING_NAVIGATION false
#define WP_ATTACHMENTS_BUTTON NO
#define openTargetBlankSafari NO

//END OF CONFIGURATION

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) AVPlayer *player;

@property (strong, nonatomic) OneSignal *oneSignal;

@property (nonatomic) int interstitialCount;


//Keeping a reference to controller that is currently playing audio. 
@property (strong, nonatomic) UIViewController* activePlayerController;
- (void) setActivePlayingViewController: (UIViewController *) active;
- (UIViewController *) activePlayingViewController;
- (void) closePlayerWithObserver: (NSObject *) observer;

//Utility methods
- (BOOL) shouldShowInterstitial;
+ (BOOL) hasPurchased;
+ (void) openUrl: (NSString *) url withNavigationController: (UINavigationController *) navController;

//Swift bridge
+ (NSString *) WooHost;
+ (NSString *) WooKey;
+ (NSString *) WooSecret;
+ (NSString *) GoogleAPI;
+ (NSString *) SoundCloudAPI;
+ (NSString *) FlickrAPI;
+ (NSString *) TumblrAPI;
+ (NSString *) FacebookToken;
+ (NSString *) InstagramToken;
+ (NSString *) PinterestToken;
+ (NSString *) TwitterAPI;
+ (NSString *) TwitterAPISecret;
+ (NSString *) TwitterToken;
+ (NSString *) TwitterTokenSecret;

+ (BOOL) LightTheme;
+ (BOOL) HidingNavigation;
+ (BOOL) TargetBlankSafari;
+ (BOOL) WpAttachmentsButton;
+ (UIColor *) GradientOne;
+ (UIColor *) GradientTwo;
@end
