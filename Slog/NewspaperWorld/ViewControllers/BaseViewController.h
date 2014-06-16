//
//  BaseViewController.h
//  NewspaperWorld
//


#import <UIKit/UIKit.h>

@class NWBookCard;
@class NWBooksCache;
/**
 @detailed This class uses for description 
 base functionality of all view controllers
 */
@interface BaseViewController : UIViewController<UIGestureRecognizerDelegate>
{
    UIAlertView*    _errorAlert;
	
	UIImageView * background;
}

@property (nonatomic, retain)   NSString* navigationBarTitle;
@property (nonatomic, readonly) UIViewController* navigationRootViewController;
@property (nonatomic, assign)   BOOL  isDetailViewController;
@property (nonatomic, readonly) UIDeviceOrientation     deviceOrientation;
@property (nonatomic, readonly) UIInterfaceOrientation  statusBarOrientation;

- (CGRect)screenBoundsForOrientation:(UIInterfaceOrientation)orientation;
- (void)initializeWithClassDescription:(NSObject*)classDescription;
- (void)defaultHandleFailExecuteMethod:(NSString*)method error:(NSError*)error;
- (void)notifySuccessfullyPurchaseBookWithID:(int)bookID;
- (void)loadBook:(NWBookCard*)bookCard URL:(NSString*)url toPath:(NSString*)path cache:(NWBooksCache*)cache;

@property (nonatomic, assign) BOOL masterIsVisible;
@property (nonatomic, readonly) UISplitViewController* splitViewController;
@property (nonatomic, retain)  UIBarButtonItem* masterButton;

- (void)showMasterView;
- (void)hideMasterView;

- (void)addMasterButton;
- (void)removeMasterButton;

+ (void)addMasterButtonForAll;
+ (void)removeMasterButtonForAll;

@end
