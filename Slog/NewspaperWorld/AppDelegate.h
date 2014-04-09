//
//  AppDelegate.h
//  Slog
//

#import "NWApiClientDelegate.h"
#import "SGHyphenator.h"

/**
 @brief This is a main application class
 */
@interface AppDelegate : UIResponder <UIApplicationDelegate, NWApiClientDelegate, UIAlertViewDelegate>
{
    NSMutableArray* _viewControllers;///array of view controllers for tabbar and splitview
    
    NSDictionary*   _notificationsViewControllers;
    
    SEL             _lastNetworkOperationSelector;
    
    
}

/**
 @brief This methods returns link to shared AppDelegate object
 */
+ (AppDelegate*)sharedAppDelegate;

@property(retain, nonatomic) UIWindow *window; /// main window of application

@property(retain, nonatomic) UITabBarController *tabBarController; ///tabbarcontroller for iphone UI

@property(retain, nonatomic) UISplitViewController *splitViewController; // splitviewcontroller for ipad

@property(retain, nonatomic) UINavigationController *detailNavigationController; // navigationcontroller for ipad

@property(retain, nonatomic) SGHyphenator * hyphenator;

@end
