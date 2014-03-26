//
//  SplashViewController.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>
#import "BaseViewController.h"

/**
 @detailed This class shows interactive splash screen after application default splash 
 screen. Application registration execute during showing this splash view.
 */
@interface SplashViewController : BaseViewController
{
    ///TODO: comment
    IBOutlet UIActivityIndicatorView* _activityIndicator;
    
    ///TODO: comment
    IBOutlet UIImageView* _splashImageView;
    
    ///TODO: comment
    IBOutlet UILabel* _loadDescriptionLabel;
    
    ///TODO: comment
    BOOL _visible;
}

///TODO: comment
@property (nonatomic, readonly) BOOL visible;

///TODO: comment
@property (nonatomic, retain) NSString* descriptionText;

///TODO: comment
+ (void)showSplashWithText:(NSString*)text;

///TODO: comment
+ (void)hideSplash;

@end
