//
//  FrontNavigationController.m
//  Universal
//
//  Created by Mu-Sonic on 25/10/2015.
//  Copyright © 2018 Sherdle. All rights reserved.
//

#import "SWRevealViewController.h"
#import "FrontNavigationController.h"
#import "TabNavigationController.h"
#import "AppDelegate.h"
#import "ConfigParser.h"
#import "Config.h"
#import "Section.h"
#import "Item.h"

#import "WordpressViewController.h"
#import "MoreViewController.h"

#import "Universal-Swift.h"

@implementation FrontNavigationController
{
    UIColor *prevShadowColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    prevShadowColor = self.revealViewController.frontViewShadowColor;
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = APP_THEME_COLOR;
    
    if (!_selectedIndexPath) {
        _selectedIndexPath  = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    if ([Config config] == nil){
        //Load loading view
        TabNavigationController *controller = [self loadingController];
        controller.viewControllers[0].hidesBottomBarWhenPushed = true;
        [viewControllers addObject:controller];
        self.viewControllers = viewControllers;
        
        //Parse config
        ConfigParser * configParser = [[ConfigParser alloc] init];
        configParser.delegate = self;
        [configParser parseConfig:CONFIG];
        return;
    } else {
        Section *section = [[Config config] objectAtIndex: _selectedIndexPath.section];
        Item *item = [section.items objectAtIndex:_selectedIndexPath.row];
    
        NSArray *tabs = item.tabs;
        if ([tabs count] > 1){
            
            if ( [tabs count] <= 5) {
                for (id subItem in tabs) {
                    TabNavigationController *controller = [self controllerFromItem:subItem];
                    [viewControllers addObject:controller];
                }
            } else {
                for (id subItem in [tabs subarrayWithRange:NSMakeRange(0, 4)]) {
                    TabNavigationController *controller = [self controllerFromItem:subItem];
                    [viewControllers addObject:controller];
                }
                
                TabNavigationController *controller = [self moreControllerFromItems:[tabs subarrayWithRange:NSMakeRange(4, [tabs count] - 4)]];
                [viewControllers addObject:controller];
            }
            
        } else {
            TabNavigationController *controller = [self controllerFromItem:[tabs objectAtIndex: 0]];
            controller.viewControllers[0].hidesBottomBarWhenPushed = true;
            [viewControllers addObject:controller];
        }
        
        self.viewControllers = viewControllers;
    }
    

}

- (void)parseSuccess:(NSMutableArray *)result {
    [Config setConfig:result];
    [self viewDidLoad];
}

- (void)parseFailed:(NSError *)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", nil)message:NO_CONNECTION_TEXT preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* retry = [UIAlertAction actionWithTitle:NSLocalizedString(@"retry", nil) style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              ConfigParser * configParser = [[ConfigParser alloc] init];
                                                              configParser.delegate = self;
                                                              [configParser parseConfig:CONFIG];
                                                          }];
    [alertController addAction:retry];
    [self presentViewController:alertController animated:YES completion:nil];
}

- ( TabNavigationController *) controllerFromItem: (Tab *) item{
    UIViewController *controller = [FrontNavigationController createViewController:item withStoryboard:self.storyboard];
    
    UIImage *tabImage = nil;
    if (item.icon != nil) {
        tabImage = [UIImage imageNamed:item.icon];
    }
    
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:item.name image:tabImage selectedImage:tabImage];
    controller.tabBarItem = tabItem;
    
    TabNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabNavigationController"];
    
    return [navigationController initWithRootViewController:controller];
}

- ( TabNavigationController *) moreControllerFromItems: (NSArray *) items{
    MoreViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MoreViewController"];
    controller.items = items;
    controller.title = NSLocalizedString(@"more", nil);
    
    UIImage *tabImage = [UIImage imageNamed:@"more"];
    
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"more", nil) image:tabImage selectedImage:tabImage];
    controller.tabBarItem = tabItem;
    
    TabNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabNavigationController"];
    
    return [navigationController initWithRootViewController:controller];
}

- ( TabNavigationController *) loadingController {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingViewController"];
    controller.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"more", nil) image:nil selectedImage:nil];
    controller.tabBarItem = tabItem;
    
    TabNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabNavigationController"];
    
    return [navigationController initWithRootViewController:controller];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

+(UIViewController *) createViewController:(Tab*) item withStoryboard:(UIStoryboard *) storyboard{
    NSString *SOCIAL_ITEMS_NAME = item.name;
    NSString *SOCIAL_ITEMS_TYPE = item.type;
    NSArray *SOCIAL_ITEMS_PARAMS = item.params;
    
    UIViewController *controller;

    if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"wordpress_old"] == NSOrderedSame) {
        
        controller = (WordpressViewController *) [storyboard instantiateViewControllerWithIdentifier:@"WordpressViewController"];
        
        ((WordpressViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    } else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"youtube"] == NSOrderedSame){
        controller = (YoutubeSwiftViewController *)  [storyboard instantiateViewControllerWithIdentifier:@"YoutubeSwiftViewController"];
        
        ((YoutubeSwiftViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    } else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"maps"] == NSOrderedSame) {
        controller = (MapsViewController *) [storyboard instantiateViewControllerWithIdentifier:@"MapsViewController"];
        
        ((MapsViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    } else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"radio"] == NSOrderedSame) {
        controller = (RadioSwiftViewController *) [storyboard instantiateViewControllerWithIdentifier:@"RadioSwiftViewController"];
        
        ((RadioSwiftViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    } else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"stream"] == NSOrderedSame) {
        controller = (TvViewController *) [storyboard instantiateViewControllerWithIdentifier:@"TvViewController"];
        
        ((TvViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    } else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"webview"] == NSOrderedSame) {
        controller = (WebViewSwiftController *) [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        
        ((WebViewSwiftController *)controller).params = SOCIAL_ITEMS_PARAMS;
    }  else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"rss"] == NSOrderedSame) {
        controller = (RssSwiftViewController *) [storyboard instantiateViewControllerWithIdentifier:@"RssSwiftViewController"];
        
        ((RssSwiftViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    }  else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"twitter"] == NSOrderedSame) {
         controller = (SocialViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SocialViewController"];
        
        ((SocialViewController *)controller).provider = [NSNumber numberWithInteger:4];
         ((SocialViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    }  else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"facebook"] == NSOrderedSame) {
        controller = (SocialViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SocialViewController"];
        
        ((SocialViewController *)controller).provider = [NSNumber numberWithInteger:1];
        ((SocialViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    }  else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"instagram"] == NSOrderedSame) {
        controller = (SocialViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SocialViewController"];
        
        ((SocialViewController *)controller).provider = [NSNumber numberWithInteger:2];
        ((SocialViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    }  else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"pinterest"] == NSOrderedSame) {
        controller = (SocialViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SocialViewController"];
        
        ((SocialViewController *)controller).provider = [NSNumber numberWithInteger:3];
        ((SocialViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    /**}  else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"facebook"] == NSOrderedSame) {
        controller = (FacebookViewController *) [storyboard instantiateViewControllerWithIdentifier:@"FacebookViewController"];
        
        ((FacebookViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    }  else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"instagram"] == NSOrderedSame) {
        controller = (InstagramViewController *) [storyboard instantiateViewControllerWithIdentifier:@"InstagramViewController"];
        
        ((InstagramViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
    } else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"pinterest"] == NSOrderedSame) {
        controller = (PinterestViewController *) [storyboard instantiateViewControllerWithIdentifier:@"PinterestViewController"];
        
        ((PinterestViewController *)controller).params = SOCIAL_ITEMS_PARAMS;*/
    }   else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"soundcloud"] == NSOrderedSame || [SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"wordpress_audio"] == NSOrderedSame) {
        controller = (AudioViewController *) [storyboard instantiateViewControllerWithIdentifier:@"AudioViewController"];
        
        ((AudioViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
        ((AudioViewController *)controller).isWordpress = [SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"wordpress_audio"] == NSOrderedSame;
    }   else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"tumblr"] == NSOrderedSame || [SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"flickr"] == NSOrderedSame) {
        controller = (PhotosViewController *) [storyboard instantiateViewControllerWithIdentifier:@"PhotosViewController"];
        
        ((PhotosViewController *)controller).params = SOCIAL_ITEMS_PARAMS;
        ((PhotosViewController *)controller).isTumblr = [SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"tumblr"] == NSOrderedSame;
    }   else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"overview"] == NSOrderedSame) {
        controller = (OverviewSwiftController *) [storyboard instantiateViewControllerWithIdentifier:@"OverviewSwiftController"];
        
        ((OverviewSwiftController *)controller).params = SOCIAL_ITEMS_PARAMS;
    }   else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"woocommerce"] == NSOrderedSame) {
        controller = (WooCommerceViewController *) [storyboard instantiateViewControllerWithIdentifier:@"WooCommerceViewController"];
        
        ((WooCommerceViewController *) controller).params = SOCIAL_ITEMS_PARAMS;
    }   else if ([SOCIAL_ITEMS_TYPE caseInsensitiveCompare:@"wordpress"] == NSOrderedSame) {
        controller = (WordpressSwiftViewController *) [storyboard instantiateViewControllerWithIdentifier:@"WordpressSwiftViewController"];
        
        ((WordpressSwiftViewController *) controller).params = SOCIAL_ITEMS_PARAMS;
    }   else {
        NSLog(@"Invalid Content Provider: %@", SOCIAL_ITEMS_TYPE);
    }
    
    controller.title = SOCIAL_ITEMS_NAME;
    
    return controller;
}

@end
