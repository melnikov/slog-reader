//
//  ReadBookViewController.h
//

#import "BaseViewController.h"
#import "FB2File.h"
#import "FB2View.h"
#import "FB2PagesGeneratorDelegate.h"
#import "DecodeOperationDelegate.h"
#import "UnzipOperationDelegate.h"
#import "FontSettingsViewController.h"
#import "BookContentViewController.h"
#import "BookmarksViewController.h"
#import "NWApiClientDelegate.h"
#import "ReaderViewController.h"

@class NWBookCacheItem;

@interface ReadBookViewController : BaseViewController<UIGestureRecognizerDelegate,
                                                       UIScrollViewDelegate,
                                                       FB2PagesGeneratorDelegate,
                                                       DecodeOperationDelegate,
                                                       UnzipOperationDelegate,
                                                       FontSettingsDelegate,
                                                       BookContentViewControllerDelegate,
                                                       BookmarksViewControllerDelegate,
                                                       NWApiClientDelegate,
                                                       ReaderViewControllerDelegate>
{
        
    IBOutlet UIView* _bottomPanel;

	IBOutlet UIView *_upperPanel;
	
	IBOutlet UILabel *titleLabel;
	
    UIButton* returnButton;
    
    IBOutlet UIView* _frontPage;    
    IBOutlet UIView* _bottomPage;
    
    IBOutlet UIView* _frontPage2;
    IBOutlet UIView* _bottomPage2;
    
    IBOutlet FB2View*   _frontFB2View;
    IBOutlet FB2View*   _backFB2View;
    
    IBOutlet FB2View *  _frontFB2View2;
    IBOutlet FB2View *  _backFB2View2;
    
    IBOutlet UIToolbar* _toolbar;
    IBOutlet UIToolbar* _toolbarWithReturn;

    IBOutlet UINavigationItem*  _customNavigationItem; 
    IBOutlet UINavigationBar*   _navigationBar;
	
    IBOutlet UIView*    _fadeView;       
 
    IBOutlet UISlider*  _bookSlider;    
    IBOutlet UILabel*  _percentReader;
    
    IBOutlet UIButton* _buyButton;

    FB2File*         _fb2File;

    NWBookCacheItem* _bookCacheItem;

    FB2PagesGenerator*  _portraitPagesGenerator;    
    FB2PagesGenerator*  _landscapePagesGenerator;    
    FB2PagesGenerator*  _currentPagesGenerator;
    
    NSOperationQueue*   _operationQueue;
    
    BOOL _nightMode;

    BOOL _toNextPageMoving;    
    BOOL _frontIsFirst;

    BOOL _isDemo;
    BOOL _isFirstRun;
   
    int  _currentPage;
    BOOL _isNoteShow;

    int                  _touchedImageID;
    NSMutableDictionary* _imageViews;
}

+ (ReadBookViewController*)createViewController;

+ (void)readBookCacheItem:(NWBookCacheItem*)item parent:(UIViewController*)parent;

- (IBAction)onBackButton:(id)sender;

- (IBAction)onShowContent:(id)sender;

- (IBAction)onShowBookmarks:(id)sender;

- (IBAction)onShowFontSettings:(id)sender;

- (IBAction)onAddBookmark:(id)sender;

- (IBAction)onSliderChanged:(id)sender;

- (IBAction)onNightModeActivate: (id)sender;

- (IBAction)buyButtonTouched:(id)sender;

@end
