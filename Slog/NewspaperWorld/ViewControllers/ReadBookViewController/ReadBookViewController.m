//
//  ReadBookViewController.m
//

#import "ReadBookViewController.h"
#import "SVProgressHUD.h"
#import "Utils.h"
#import "BookmarksViewController.h"
#import "UnzipOperation.h"
#import "DecodeOperation.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "NWSettings.h"
#import "NWDataModel.h"
#import "NWBookCacheItem.h"
#import "FB2File.h"
#import "FB2PageData.h"
#import "FB2PageDataItem.h"
#import "FB2Section.h"
#import "FB2Body.h"
#import "Constants.h"
#import "NWApiClient.h"
#import "AFHTTPRequestOperation.h"
#import "QuartzCore/QuartzCore.h"
#import "FB2PageImageItem.h"
#import "ReaderDocument.h"
#import "ReaderViewController.h"
#import "ASMediaFocusManager.h"
#import "FB2PageLinkItem.h"
#import "NWDetailPosition.h"

#define MAX_FONT_SIZE 22
#define MIN_FONT_SIZE 12

static const float THERESOLD = 0.15; 
static const unsigned long long MIN_ZIP_FILE_SIZE = 20; // min header for ZIP file is 20 byte

typedef enum
{
    MP_NEXT_PAGE = 0,
    MP_PREV_PAGE,
    MP_NEXT_PAGE_ANIMATION,
    MP_PREV_PAGE_ANIMATION
} MovePageEnumerate;

@interface ReadBookViewController () <ASMediasFocusDelegate>
{
    int                 _offset;
    int                 _itemID;
    BOOL                _isChangedPage;
    BOOL                _visibleMenu;
}

- (void)initializeNavigationBar;
- (void)initializeReader;
- (BOOL)initializeWithBookCacheItem:(NWBookCacheItem*)item;
- (void)deinitializeControls;

- (void)showPanels;
- (void)hidePanels;

- (void)showBlackLayout;
- (void)fadeOutLayout;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)openBook;
- (void)openFB2FromData:(NSData*)fb2Data;
- (void)unzipFile:(NSString*)path needDeleteSource:(BOOL)needDelete;
- (void)decodeFile:(NSString*)path;
- (BOOL)isFileZip:(NSString*)path;

- (void)generateBookPages;

- (void)setNightMode:(BOOL)active;
- (void)showCurrentPage;

- (void)updateColors;
- (void)updateChapterOffsets;
- (void)updateBookmarkOffsets;
- (void)updateBookmarksCountForChapters;
- (void)updateBuyButton;
- (void)updatePageImageViews;
- (void)updatePageImageViewsPositions;
- (void)removePageImageViews;

- (void)switchPage:(MovePageEnumerate)command;

- (void)initializeGestureRecognizers;
- (void)gestureRecognizerSwype:(UIGestureRecognizer *)sender;
- (void)gestureRecognizerTap:(UIGestureRecognizer *)sender;
- (void)removeGestureRecognizers:(UIView*)view;

- (int) getOffsetValue;
- (void)createTemporallyBookmarkForCurrentPosition; // before switching orientation
- (void)updateCurrentPage;
- (void)closeView;
- (void)saveCurrentPositionInBook;

- (BOOL)bookFileIsIncorrect:(NSString*)path;

- (void)detectTouchOnImage:(CGPoint)pt;
- (BOOL)detectTouchOnLink:(CGPoint)pt;

- (void)showExternalLink:(FB2PageLinkItem*)item;
- (void)showInternalLink:(FB2PageLinkItem*)item;

- (int)pageIndexForNodeID:(NSString*)ID;

- (void)showReturnButton;
- (void)hideReturnButton;

@property (nonatomic, assign) int currentPage;
@property (nonatomic, retain) UIPopoverController* popover;
@property (nonatomic, retain) ASMediaFocusManager* focusManager;
@property (nonatomic, retain) NWDetailPosition*      oldPosition;

@end

@implementation ReadBookViewController

@synthesize popover;
@synthesize currentPage = _currentPage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];      
        _currentPage        = 0;
        _frontIsFirst       = YES;
        _toNextPageMoving   = NO;
        _isDemo             = YES;
        _isChangedPage      = YES;
        _visibleMenu        = NO;
        _touchedImageID     = -1;
        _imageViews = [[NSMutableDictionary alloc] init];
        _isFirstRun = YES;
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{    
    [self deinitializeControls];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    [_operationQueue release];
    [_portraitPagesGenerator release];
    [_landscapePagesGenerator release];
    [_bookCacheItem release];
    [_fb2File release];
    [_focusManager release];
    [_imageViews release];
    [_toolbar release];
    [_toolbarWithReturn release];
    [returnButton release];

    [_frontFB2View2 release];
    [_backFB2View2 release];
	[_upperPanel release];
	[titleLabel release];
    [super dealloc];
}


#pragma mark Vieww life-cycle

- (void)saveCurrentPositionInBook
{
    if (self.currentPage >= 0 && !_currentPagesGenerator.generatingPages) {
        _offset = [self getOffsetValue];
        FB2PageDataItem* pageItem = [[_currentPagesGenerator pageAtIndex:self.currentPage].items itemAtIndex:0];
        _itemID = pageItem.fb2ItemID;
        NWBookmarkItem* positionBookmark = nil;
        
        if ((_isNoteShow) && (_oldPosition)) {
                    // title is unimportant info
            positionBookmark =[[NWBookmarkItem alloc] initWithTitle:@"unknown" fb2ItemID:_oldPosition.itemID];
            positionBookmark.offset = _oldPosition.offset;
        } else {
                    // title is unimportant info
            positionBookmark = [[NWBookmarkItem alloc] initWithTitle:@"unknown" fb2ItemID:_itemID];
            positionBookmark.offset = _offset;
        }


        NWBookCacheItem* item = [[NWDataModel sharedModel] cacheItemWithBookID:_bookCacheItem.bookCard.ID];
        if (item) {
            item.positionBookmark = positionBookmark;
        }
        
        [[[NWDataModel sharedModel] purchasedBooksCache] save];
        [[[NWDataModel sharedModel] demoFragmentsCache] save];
        
        [positionBookmark release];
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([Utils isDeviceiPad]){
        if ([Utils isPortrait]){
            _frontPage2.hidden = YES;
            _bottomPage2.hidden = YES;
            
            _frontFB2View2.hidden = YES;
            _backFB2View2.hidden = YES;
            
            CGRect frame = _frontPage.frame;
            _frontPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 1024 ,768);
            _bottomPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 1024 ,768);
            _frontFB2View2.frame = CGRectMake(frame.origin.x, frame.origin.y, 1024 ,768);
            _backFB2View2.frame = CGRectMake(frame.origin.x, frame.origin.y, 1024 ,768);
        }else{
            _frontPage2.hidden = NO;
            _bottomPage2.hidden = NO;
            
            _frontFB2View2.hidden = NO;
            _backFB2View2.hidden = NO;
            
            CGRect frame = _frontPage.frame;
            
            _frontPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 512,frame.size.height);
            _bottomPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 512,frame.size.height);
            //_frontFB2View.frame = CGRectMake(frame.origin.x, frame.origin.y, 502,frame.size.height);
            //_backFB2View.frame = CGRectMake(frame.origin.x, frame.origin.y, 502,frame.size.height);

        }
    }

    
    [self initializeGestureRecognizers];
    [self initializeReader];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentPositionInBook) name:@"didEnterBackground" object:nil];
    _bookSlider.minimumValue = 0;

    self.focusManager = [[[ASMediaFocusManager alloc] init] autorelease];
    self.focusManager.delegate = self;
    self.focusManager.closeButtonTitle = NSLocalizedString(@"IDS_CLOSE", nil);
    self.focusManager.isCloseButtonVisible = YES;
 }

- (void)viewDidUnload
{ 
    [self deinitializeControls];
    [_frontFB2View2 release];
    _frontFB2View2 = nil;
    [_backFB2View2 release];
    _backFB2View2 = nil;
	[_upperPanel release];
	_upperPanel = nil;
	[titleLabel release];
	titleLabel = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.navigationController)
        [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation]; 
    [self createTemporallyBookmarkForCurrentPosition];
    
    if ([Utils isDeviceiPad]){
        if (!UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)){
            [self updateLandscape];
        }else{
            [self updatePortrait];
        }
    }
    
    [self generateBookPages];
    _isChangedPage = NO;
}

-(void)updateLandscape
{
    _frontPage2.hidden = NO;
    _bottomPage2.hidden = NO;
    
    _frontFB2View2.hidden = NO;
   _backFB2View2.hidden = NO;
    
    CGRect frame = _frontPage.frame;
    CGRect frame2 = _frontFB2View2.frame;
    
    _frontPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 512,frame.size.height);
    _bottomPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 512,frame.size.height);
    
    _frontFB2View2.frame = CGRectMake(20, 20, 472,frame2.size.height);
    _backFB2View2.frame = CGRectMake(20, 20, 472,frame2.size.height);
}

-(void) updatePortrait
{
    _frontPage2.hidden = YES;
    _bottomPage2.hidden = YES;
    
    _frontFB2View2.hidden = YES;
    _backFB2View2.hidden = YES;
    
    CGRect frame = _frontPage.frame;
    _frontPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 768,frame.size.height);
    _bottomPage.frame = CGRectMake(frame.origin.x, frame.origin.y, 768,frame.size.height);
    _frontFB2View2.frame = CGRectMake(frame.origin.x, frame.origin.y, 768,frame.size.height);
    _backFB2View2.frame = CGRectMake(frame.origin.x, frame.origin.y, 768,frame.size.height);
}

#pragma mark Public implementation

+ (void)readBookCacheItem:(NWBookCacheItem *)item parent:(UIViewController *)parent
{
    if (!item || !parent)
        return;
    
    [NWDataModel sharedModel].lastReadedBookID = item.bookCard.ID;
    [[NWDataModel sharedModel] saveLastBook];

    ReadBookViewController* viewController = [ReadBookViewController createViewController];
    [viewController initializeWithBookCacheItem:item];

    UINavigationController* navi = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    [parent presentModalViewController:navi animated:NO];
}

+ (ReadBookViewController*)createViewController
{
    return [[[ReadBookViewController alloc] initWithNibName:@"ReadBookViewController" bundle:nil] autorelease];
}

- (BOOL)initializeWithBookCacheItem:(NWBookCacheItem *)item
{
    if (!item || ![Utils fileExistsAtPath:item.localPath])
    {
        return NO;
    }
    [_bookCacheItem release];
    _bookCacheItem = [item retain];
    return YES;
}

#pragma mark Buttons Actions

- (IBAction)onBackButton:(id)sender
{
    [SVProgressHUD dismiss];
    [self saveCurrentPositionInBook];
    [_portraitPagesGenerator clear];
    [_landscapePagesGenerator clear];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onShowContent:(id)sender
{
    if ([SVProgressHUD isVisible])
        return;
    
    BookContentViewController* vc = [BookContentViewController createViewController];
    vc.delegate = self;
    [vc initializeWithBookCacheItem:_bookCacheItem];
    UINavigationController* navi = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    if ([Utils isDeviceiPad])
    {
        if (self.popover.isPopoverVisible)
            return;
                
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:navi] autorelease];
        vc.parentPopover = self.popover;
//        [popover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender 
//                        permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
		[popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
        [self presentModalViewController:navi animated:YES];    
}

- (IBAction)onShowBookmarks:(id)sender
{
    if ([SVProgressHUD isVisible])
        return;
    
    BookmarksViewController* vc = [BookmarksViewController createViewController];
    vc.delegate = self;
    [vc initializeWithBookCacheItem:_bookCacheItem];
    UINavigationController* navi = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];

    if ([Utils isDeviceiPad])
    {
        if (self.popover.isPopoverVisible)
            return;
        
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:navi] autorelease];
        vc.parentPopover = self.popover;
//        [popover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender
//                        permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
		[popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
        [self presentModalViewController:navi animated:YES];  
}

- (IBAction)onShowFontSettings:(id)sender
{
    if ([SVProgressHUD isVisible])
        return;
    
    FontSettingsViewController* vc = [FontSettingsViewController createViewController];
    vc.delegate = self;
    UINavigationController* navi = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    if ([Utils isDeviceiPad])
    {
        if (self.popover.isPopoverVisible)
            return;
        
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:navi] autorelease];
        vc.parentPopover = self.popover;
//        [popover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender
//                        permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
		[popover presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
        [self presentModalViewController:navi animated:YES];
}

- (IBAction)onAddBookmark:(id)sender
{
    if ([SVProgressHUD isVisible])
        return;
    
    FB2PageData* page = [_currentPagesGenerator pageAtIndex:self.currentPage];
    if (!page)
        return;
    
    FB2PageDataItem* item = nil;
    NSString* stringData = nil;
    
    for(int i = 0; i < page.items.count; i++) {
        item = [page.items itemAtIndex:i];
        
        if ([item.data isKindOfClass:[NSString class]]) {
            stringData = (NSString*)item.data;
            if (stringData.length > 1)
                break;
        }
    }
    
    if (stringData == nil) {
        stringData = @" ";
    }
    
    if (item == nil)
        return;

    NSString* titleBookmark = stringData;
     
    NWBookmarkItem* bookmark = [NWBookmarkItem itemWithTitle:titleBookmark fb2ItemID:item.fb2ItemID];  

    bookmark.offset = [self getOffsetValue];
    NWBookmarkItem* exists   = [_bookCacheItem.bookmarks bookmarkWithFB2ItemID:bookmark.fb2ItemID offset:bookmark.offset];

    if (exists)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_BOOKMARK_EXISTS", @"")];
        return;
    }

    bookmark.positionInBook = (double)(self.currentPage)/(double)(_currentPagesGenerator.pagesCount-1);
    
    [_bookCacheItem.bookmarks addBookmark:bookmark];
    [self updateBookmarksCountForChapters];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"IDS_BOOKMARK_ADDED", @"")];
    
    [[NWDataModel sharedModel].purchasedBooksCache save];
    [[NWDataModel sharedModel].demoFragmentsCache save];
}

- (IBAction)onSliderChanged:(id)sender
{
    if (![sender isKindOfClass:[UISlider class]])
        return;
    
    UISlider* slider = (UISlider*)sender;
    self.currentPage = slider.value;
    
    [self hideReturnButton];
}

-(IBAction)onNightModeActivate: (id)sender
{
    if ([SVProgressHUD isVisible])
        return;
    
    _nightMode = !_nightMode;
    [self setNightMode:_nightMode];
}

#pragma mark Gesture recognizers callbacks

- (void)gestureRecognizerSwype:(UIGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        UISwipeGestureRecognizer* rec = (UISwipeGestureRecognizer*)sender;


        if (rec) {
            if (rec.direction == UISwipeGestureRecognizerDirectionRight) {
                [self switchPage:MP_PREV_PAGE];
            } else if (rec.direction == UISwipeGestureRecognizerDirectionLeft){
                [self switchPage:MP_NEXT_PAGE];
            }
        }
    }
}

- (void)gestureRecognizerTap:(UIGestureRecognizer*)sender
{
    CGPoint touchPoint = [sender locationOfTouch:0 inView:self.view];
    int screenWidth = self.view.bounds.size.width;

    if ((touchPoint.x > (1-THERESOLD)*screenWidth)) {
        [self switchPage:MP_NEXT_PAGE];
    } else if (touchPoint.x < THERESOLD*screenWidth) {
        [self switchPage:MP_PREV_PAGE];
    } else {
        // center area on screen
        if (_navigationBar.alpha > 0.9)
            [self hidePanels];
        else
            [self showPanels];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.focusManager.isShowing)
        return NO;

  

    CGPoint touchPoint = [touch locationInView:self.view];

    // cancel touches on UIButtons
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }

    // cancel touches on bottom UIToolBar panel
    if ((touchPoint.y > (self.view.bounds.size.height-_bottomPanel.bounds.size.height)) && (_bottomPanel.alpha > 0.9)) {
        return NO;
    }

    // cancel touch on navigation panel for Ipad
    if ([Utils isDeviceiPad]) {
        if ((touchPoint.y < _navigationBar.bounds.size.height) && (_bottomPanel.alpha > 0.9)) {
            return NO;
        }
    }

    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
        return YES;
    
    CGPoint fb2ViewPoint = [self.view convertPoint:touchPoint toView:_frontFB2View];
    if ([self detectTouchOnLink:fb2ViewPoint] == YES)
        return NO;
    
    CGPoint fb2ViewPoint2 = [self.view convertPoint:touchPoint toView:_frontFB2View2];
    if ([self detectTouchOnLink:fb2ViewPoint2] == YES)
        return NO;

    [self detectTouchOnImage:fb2ViewPoint];

    return YES;
}

#pragma mark Private methods

- (void)showReturnButton
{    
    if (returnButton == nil) {
        returnButton = [[UIButton alloc] initWithFrame:CGRectMake(_buyButton.frame.origin.x, _buyButton.frame.origin.y-_buyButton.frame.size.height-4.0, _buyButton.frame.size.width, _buyButton.frame.size.height)];
        [returnButton setBackgroundImage:[UIImage imageNamed:@"red_btn_bg"] forState:UIControlStateNormal];
        [returnButton setTitle:NSLocalizedString(@"IDS_RETURN_READING", @"return") forState:UIControlStateNormal];
        [returnButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
        [returnButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        returnButton.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:([Utils isDeviceiPad] ? 17 : 15)];
        [returnButton addTarget:self
                         action:@selector(returnButtonTouched:)
               forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:returnButton];
        returnButton.hidden = NO;
    } else {
        returnButton.hidden = NO;
    }
    
    _isNoteShow = YES;
}

- (void)hideReturnButton
{
    returnButton.hidden = YES;
    _isNoteShow = NO;
}

- (IBAction)returnButtonTouched:(NSObject*)sender
{
    if (self.oldPosition)
    {
        _itemID = self.oldPosition.itemID;
        _offset = self.oldPosition.offset;
        [self updateCurrentPage];
    }
    self.oldPosition = nil;
    [self hideReturnButton];

}

- (int)pageIndexForNodeID:(NSString*)ID
{
    int pageIndex = -1;
    for (pageIndex = 0; pageIndex < _currentPagesGenerator.pagesCount; pageIndex++)
    {
        FB2PageData* page = [_currentPagesGenerator pageAtIndex:pageIndex];
        if (!page)
            continue;

        for (NSString* nodeID in page.nodeIDs)
        {
            if ([nodeID isEqualToString:ID])
            {
                return pageIndex;
            }
        }
    }
    if (pageIndex == _currentPagesGenerator.pagesCount)
        pageIndex = -1;
    return pageIndex;
}

- (void)showExternalLink:(FB2PageLinkItem*)item
{
    if (!item || item.isLocal)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_INCORRECT_LINK", @"")];
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.href]];
}

- (void)showInternalLink:(FB2PageLinkItem*)item
{
    if (!item || !item.isLocal)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_INCORRECT_LINK", @"")];
        return;
    }

    int pageIndex = [self pageIndexForNodeID:item.href];
    if (pageIndex == -1)
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_INCORRECT_LINK", @"")];
        return;
    }

    FB2PageDataItem* pageItem = [[_currentPagesGenerator pageAtIndex:_currentPage].items itemAtIndex:0];
    if (pageItem)
        self.oldPosition = [[[NWDetailPosition alloc] initWithID:pageItem.fb2ItemID offset:[self getOffsetValue]] autorelease];

    self.currentPage = pageIndex;

    [self createTemporallyBookmarkForCurrentPosition];

    [self showReturnButton];
}

- (BOOL)detectTouchOnLink:(CGPoint)pt
{
    FB2PageData* page = [_currentPagesGenerator pageAtIndex:_currentPage];
    FB2PageData* page2 = nil;
    
    if([Utils isDeviceiPad] && ![Utils isPortrait]){
        page2 = [_currentPagesGenerator pageAtIndex:_currentPage+1];
    }
    
    BOOL find = NO;
    
    if (page)
        find = [self findLinkByPage:page andPoint:pt];
    
    
    if (page2 && !find)
        find = [self findLinkByPage:page2 andPoint:pt];
        
    return find;
}

-(BOOL) findLinkByPage:(FB2PageData*) page andPoint:(CGPoint)pt
{
    for (int i = 0; i < page.links.count; i++)
    {
        FB2PageLinkItem* linkItem = (FB2PageLinkItem*)[page.links itemAtIndex:i];
        if ([linkItem isKindOfClass:[FB2PageLinkItem class]])
        {
            if(CGRectContainsPoint(linkItem.frame, pt))
            {
                if (linkItem.isLocal)   [self showInternalLink:linkItem];
                else                    [self showExternalLink:linkItem];
                return YES;
            }
        }
    }
    return NO;
}

- (void)detectTouchOnImage:(CGPoint)pt
{
    FB2PageData* page = [_currentPagesGenerator pageAtIndex:_currentPage];
    
    FB2PageData* page2 = nil;
    
    if([Utils isDeviceiPad] && ![Utils isPortrait]){
        page2 = [_currentPagesGenerator pageAtIndex:_currentPage+1];
    }
    
    if (page){
        [self findImageByPage:page andPoint:pt];
    }
    if (page2){
        [self findImageByPage:page2 andPoint:pt];
    }

}

-(void) findImageByPage:(FB2PageData*) page andPoint:(CGPoint)pt
{
    for (int i = 0; i < page.items.count; i++)
    {
        FB2PageDataItem* pageItem = [page.items itemAtIndex:i];
        if ([pageItem isKindOfClass:[FB2PageImageItem class]])
        {
            if(!CGRectContainsPoint(pageItem.frame, pt))
            {
                _touchedImageID = -1;
            }
            else
            {
                _touchedImageID = pageItem.fb2ItemID;
                break;
            }
        }
    }

}

- (void)removePageImageViews
{
    for(UIView* subView in _frontFB2View.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }
    }
    
    for(UIView* subView in _frontFB2View2.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }
    }
}

- (void)updatePageImageViewsPositions
{
    for(UIView* subView in _frontFB2View.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            
        }
    }
}

- (void)updatePageImageViews
{
    NSMutableArray* imageViews = [[[NSMutableArray alloc] init] autorelease];

    FB2PageData* page = [_currentPagesGenerator pageAtIndex:_currentPage];
    
    FB2PageData* page2 = nil;
    
    if([Utils isDeviceiPad] && ![Utils isPortrait]){
        page2 = [_currentPagesGenerator pageAtIndex:_currentPage+1];
    }
    
    if (page)
    {
        for (int i = 0; i < page.items.count; i++)
        {
            FB2PageDataItem* pageItem = [page.items itemAtIndex:i];
            if ([pageItem isKindOfClass:[FB2PageImageItem class]])
            {
                FB2PageImageItem* imageItem = (FB2PageImageItem*)pageItem;
                if (imageItem.canZoom)
                {
                    UIImageView* imageView = [[[UIImageView alloc] initWithImage:imageItem.originalImage] autorelease];
                    [imageView setFrame:imageItem.frame];
                    [imageView setTag:imageItem.fb2ItemID];

                    [_frontFB2View addSubview:imageView];
                    [imageViews addObject:imageView];
                }
            }
        }
    }
    
    if (page2)
    {
        for (int i = 0; i < page2.items.count; i++)
        {
            FB2PageDataItem* pageItem = [page2.items itemAtIndex:i];
            if ([pageItem isKindOfClass:[FB2PageImageItem class]])
            {
                FB2PageImageItem* imageItem = (FB2PageImageItem*)pageItem;
                if (imageItem.canZoom)
                {
                    UIImageView* imageView = [[[UIImageView alloc] initWithImage:imageItem.originalImage] autorelease];
                    [imageView setFrame:imageItem.frame];
                    [imageView setTag:imageItem.fb2ItemID];
                    
                    [_frontFB2View2 addSubview:imageView];
                    [imageViews addObject:imageView];
                }
            }
        }
    }
    
    [self.focusManager installOnViews:imageViews];
}

- (void)zoomImage:(UIImage*)image fromRect:(CGRect)rect
{
    NSMutableArray* imageViews = [[[NSMutableArray alloc] init] autorelease];
    for(UIView* subView in _frontFB2View.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            [imageViews addObject:subView];
        }
    }
    
    if([Utils isDeviceiPad] && ![Utils isPortrait])
    {
        for(UIView* subView in _frontFB2View2.subviews)
        {
            if ([subView isKindOfClass:[UIImageView class]])
            {
                [imageViews addObject:subView];
            }
        }
    }
    
    [self.focusManager installOnViews:imageViews];
}

- (void)zoomInTouchedImage
{
    if (_touchedImageID == -1)
        return;

    FB2PageData* page = [_currentPagesGenerator pageAtIndex:_currentPage];
    FB2PageData* page2 = nil;
    
    if([Utils isDeviceiPad] && ![Utils isPortrait])
    {
       page2 = [_currentPagesGenerator pageAtIndex:_currentPage+1];
    }
    
    if (page)  [self zoomInTouchByPage:page];
    if (page2) [self zoomInTouchByPage:page2];
    
}

-(void) zoomInTouchByPage:(FB2PageData*) page
{
    FB2PageDataItem* item = [page.items itemWithID:_touchedImageID];
    if (item)
    {
        if ([item isKindOfClass:[FB2PageImageItem class]])
        {
            FB2PageImageItem* imageItem = (FB2PageImageItem*)item;
            if (imageItem)
            {
                
                [self zoomImage:imageItem.originalImage fromRect:imageItem.frame];
                
            }
        }
    }

}

- (void)initializeGestureRecognizers
{
    UISwipeGestureRecognizer* swipeLeft =
        [[[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                   action:@selector(gestureRecognizerSwype:)] autorelease];
    [swipeLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    swipeLeft.delegate = self;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer* gestureRecognizerR =
        [[[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                   action:@selector(gestureRecognizerSwype:)] autorelease];
    [gestureRecognizerR setDirection:(UISwipeGestureRecognizerDirectionRight)];
    gestureRecognizerR.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizerR];
    
    UITapGestureRecognizer* tap =
        [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                 action:@selector(gestureRecognizerTap:)] autorelease];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)setCurrentPage:(int)page
{
    if (page != _currentPage)
    {
        _currentPage = page;
        [self createTemporallyBookmarkForCurrentPosition];
        [self showCurrentPage];
        _isChangedPage = YES;
    }
}

- (void)closeView
{
  [self dismissModalViewControllerAnimated:NO];
}

- (void)createTemporallyBookmarkForCurrentPosition
{
    if (!_isChangedPage)
        return;
    
    _offset = [self getOffsetValue];
    FB2PageDataItem* pageItem = [[_currentPagesGenerator pageAtIndex:self.currentPage].items itemAtIndex:0];
    _itemID = pageItem.fb2ItemID;
}

- (void)removeGestureRecognizers:(UIView*)view
{
    if (!view) {
        return;
    }
    
    NSArray* recognizers = view.gestureRecognizers;
    
    for(int i = 0; i < recognizers.count; i++) {
        [view removeGestureRecognizer:[recognizers objectAtIndex:i]];
    }
}

- (int)getOffsetValue
{
    int offset = 0;

    if (self.currentPage >= 0)
    {
       
        FB2PageDataItem* firstItem = [[_currentPagesGenerator pageAtIndex:self.currentPage].items
                                                              itemAtIndex:0];

        int pageBackShift = 1;
        FB2PageData* prevPage = [_currentPagesGenerator pageAtIndex:(self.currentPage - pageBackShift)];
        
        while (prevPage)
        {
            for (int i = prevPage.items.count - 1; i >= 0 ; i--)
            {
                FB2PageDataItem* item = [prevPage.items itemAtIndex:i];
                if (item.fb2ItemID == firstItem.fb2ItemID)
                {
                    if ([item.data isKindOfClass:[NSString class]])
                        offset += ((NSString*)item.data).length;
                }
                else
                    return offset;
            }

            pageBackShift++;
            prevPage = [_currentPagesGenerator pageAtIndex:(self.currentPage - pageBackShift)];
        }
    }    
    return offset;
}

- (void)openBook
{
    _isDemo = [self isFileZip:_bookCacheItem.localPath];
    if (_isDemo)
        [self unzipFile:_bookCacheItem.localPath needDeleteSource:NO];
    else
        [self decodeFile:_bookCacheItem.localPath];
}

- (void)initializeReader
{    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_PLEASE_WAIT", @"")];
    [self showBlackLayout];    
    [self initializeNavigationBar];
    
    [_frontFB2View setBackgroundColor:[UIColor clearColor]];
    [_backFB2View setBackgroundColor:[UIColor clearColor]];
    
    if ([Utils isDeviceiPad]){
        [_frontFB2View2 setBackgroundColor:[UIColor clearColor]];
        [_backFB2View2 setBackgroundColor:[UIColor clearColor]];
    }

    _nightMode = [[NWSettings sharedSettings].readerBackgroundColor isEqual:[UIColor blackColor]];
    [self updateColors];
    
    [_buyButton setHidden:YES];    
    NSString* title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"IDS_BUY", @""), _bookCacheItem.bookCard.bookPrice];
    [_buyButton setTitle:title forState:UIControlStateNormal];

    [_bottomPage setExclusiveTouch:YES];
    [_frontPage setExclusiveTouch:YES];    
    
    if ([Utils isDeviceiPad]){
        [_bottomPage2 setExclusiveTouch:YES];
        [_frontPage2 setExclusiveTouch:YES];
    }
    
    [self performSelectorInBackground:@selector(openBook) withObject:nil];
}

- (void)updateBuyButton
{    
    BOOL buyHidden = !(_isDemo && (self.currentPage == _currentPagesGenerator.pagesCount - 1));
    [_buyButton setHidden:buyHidden]; 
}

- (void)loadBook:(NWBookCard*)bookCard URL:(NSString*)url toPath:(NSString*)path cache:(NWBooksCache*)cache
{
    if (!bookCard)
        return;

    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_LOADING", @"")];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *loadOperation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    
    loadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [loadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Successfully downloaded file to %@", path);
         
         [cache addCacheItemForBookCard:bookCard
                          localFileName:path];
         [cache save];
         NWBookCacheItem* item = [cache cacheItemWithID:bookCard.ID];
         [self initializeWithBookCacheItem:item];
         [self performSelectorOnMainThread:@selector(initializeReader) withObject:nil waitUntilDone:NO];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Unable to download book for URL %@", url);
         [SVProgressHUD showErrorWithStatus:@"Unable to download book"];
     }];
    
    [loadOperation start];
}


- (IBAction)buyButtonTouched:(id)sender
{
    NWBookCacheItem* item  = [[NWDataModel sharedModel].purchasedBooksCache cacheItemWithID:_bookCacheItem.bookCard.ID];
    if (!item)
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_PERFORMING_PURCHASE", @"")];
        [[NWApiClient sharedClient] buyBookWithID:_bookCacheItem.bookCard.ID delegate:self];
    }
    else
        [ReadBookViewController readBookCacheItem:item parent:self];
}

- (void)loadFullVersion
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_LOADING", @"")];
    
    [[NWApiClient sharedClient] getURLOfFullVersionBookWithID:_bookCacheItem.bookCard.ID delegate:self];
}

- (void)switchPage:(MovePageEnumerate)command
{
    if (command == MP_NEXT_PAGE)
    {
        if (self.currentPage < _bookSlider.maximumValue)
        {
            if([Utils isDeviceiPad] && ![Utils isPortrait])
                self.currentPage += 2;
            else
                self.currentPage += 1;
            
        }
    }
    else if (command == MP_PREV_PAGE)
    {
        if (self.currentPage > 0){
            if([Utils isDeviceiPad] && ![Utils isPortrait])
                self.currentPage -= 2;
            else
                self.currentPage -= 1;
        }
    }
}

- (void)initializeWithClassDescription:(NSObject*)classDescription
{
    if (![classDescription isKindOfClass:[NWBookCacheItem class]])
        return;
    
    NWBookCacheItem* bookItem = (NWBookCacheItem*)classDescription;
    
    [self initializeWithBookCacheItem:bookItem];
}

- (void)initializeNavigationBar
{    
    _customNavigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"IDS_BACK_CATALOG", @"")
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(onBackButton:)] autorelease];
    
    
    if ([Utils isDeviceiPad])
    {
        UIBarButtonItem *buttons = [[UIBarButtonItem alloc] initWithCustomView:_toolbar];
        _customNavigationItem.rightBarButtonItem = buttons;
        [buttons release];
    }
    
    _toolbar.clearsContextBeforeDrawing = NO;
    _toolbar.clipsToBounds = NO;
    if ([Utils isDeviceiPad])
        _toolbar.barStyle = -1; // clear background

    _toolbarWithReturn.clearsContextBeforeDrawing = NO;
    _toolbarWithReturn.clipsToBounds = NO;
    if ([Utils isDeviceiPad])
        _toolbarWithReturn.barStyle = -1; // clear background
    
    [self hideReturnButton];

     _customNavigationItem.title = _bookCacheItem.bookCard.title;
	titleLabel.text = _bookCacheItem.bookCard.title;
}

- (void)deinitializeControls
{
    [_toolbar release];         _toolbar = nil;    
    [_bottomPanel release];     _bottomPanel = nil;
    [_customNavigationItem release];   _customNavigationItem = nil;
    [_navigationBar release];   _navigationBar = nil;
    [_fadeView release];        _fadeView = nil;
    [popover release];          popover = nil;
    [self removeGestureRecognizers:_frontFB2View];
    [self removeGestureRecognizers:_backFB2View];
    [_frontFB2View release];    _frontFB2View = nil;
    [_backFB2View release];     _backFB2View = nil;
    [_bookSlider release];      _bookSlider = nil;
    [_frontPage release];       _frontPage = nil;
    [_bottomPage release];      _bottomPage = nil;
    [_percentReader release];   _percentReader = nil;
    [_buyButton release];       _buyButton = nil;
}

- (void)openFB2FromData:(NSData*)fb2Data
{
    if (!_fb2File)
        _fb2File = [[FB2File alloc] init];

    if (!_currentPagesGenerator)
    {
        _portraitPagesGenerator = [[FB2PagesGenerator alloc] init];
        _landscapePagesGenerator = [[FB2PagesGenerator alloc] init];
        
        _currentPagesGenerator = (UIInterfaceOrientationIsPortrait(self.statusBarOrientation)) ? _portraitPagesGenerator : _landscapePagesGenerator;
    }
    
    if ([_fb2File openFb2FileWithData:fb2Data])
    {
        [_bookCacheItem.bookContent loadFromFB2File:_fb2File];
        [self generateBookPages];
    }
    [self performSelectorOnMainThread:@selector(fadeOutLayout)
                           withObject:nil
                        waitUntilDone:YES];
}

- (void)updateChapterOffsets
{   
    for (int i = 0; i < _bookCacheItem.bookContent.count; i++)
    {
        NWBookContentItem* item = [_bookCacheItem.bookContent contentItemAtIndex:i];
        if (item)
        {
            int pageIndex = [_currentPagesGenerator pageIndexForFB2ItemID:item.titleID offset:item.offset];
            if (pageIndex != -1)
            {
                item.positionInBook = (_currentPagesGenerator.pagesCount == 1) ? 1.0 : (double)(pageIndex)/((double)(_currentPagesGenerator.pagesCount - 1));
            }
        }
    }    
}

- (void)updateBookmarkOffsets
{
    for (int i = 0; i < _bookCacheItem.bookmarks.count; i++)
    {
        NWBookmarkItem* item = [_bookCacheItem.bookmarks bookmarkAtIndex:i];
        if (item)
        {
            int pageIndex = [_currentPagesGenerator pageIndexForFB2ItemID:item.fb2ItemID offset:item.offset];
            if (pageIndex != -1)
            {
                item.positionInBook = (_currentPagesGenerator.pagesCount == 1) ? 1.0 : (double)(pageIndex)/((double)(_currentPagesGenerator.pagesCount - 1));
            }
        }
    }
}

- (int)bookmarksCountForSection:(FB2Section*)section
{
    int bookmarksCount = 0;
    if (section)
    {
        for (int i = 0; i < _bookCacheItem.bookmarks.count; i++)
        {
            NWBookmarkItem* bookmark = [_bookCacheItem.bookmarks bookmarkAtIndex:i];
            if ([section containsItemWithID:bookmark.fb2ItemID])
            {
                bookmarksCount++;
            }
        }
    
        for (FB2Section* child in section.subSections)
        {
            bookmarksCount += [self bookmarksCountForSection:child];
        }
        
        NWBookContentItem* chapter = [_bookCacheItem.bookContent contentItemWithID:section.itemID];
        if (chapter)
        {
            chapter.bookmarksCount = bookmarksCount;
        }
    }
    return bookmarksCount;
}

- (void)updateBookmarksCountForChapters
{    
    NSArray* bodies = _fb2File.bodies;
       
    for (FB2Body* body in bodies)
    {
        for (FB2Section* section in body.sections)
        {
            [self bookmarksCountForSection:section];          
        }
    }

}

- (void)showCurrentPage
{
    _frontFB2View.currentPage = self.currentPage;
    _backFB2View.currentPage = self.currentPage;
    [_frontFB2View setNeedsDisplay];
    [_backFB2View setNeedsDisplay];
    
    if([Utils isDeviceiPad] && ![Utils isPortrait])
    {
        _frontFB2View2.currentPage = self.currentPage+1;
        _backFB2View2.currentPage = self.currentPage+1;
        [_frontFB2View2 setNeedsDisplay];
        [_backFB2View2 setNeedsDisplay];
    }
    
    [_bookSlider setValue:self.currentPage];
    
    double percentLabel = (_currentPagesGenerator.pagesCount == 1) ? 100.0 : ((double)(self.currentPage)/((double)(_currentPagesGenerator.pagesCount - 1))*100);
    
    if (percentLabel > 0) {
        _percentReader.text = (percentLabel >= 100) ? @"100%" :[NSString stringWithFormat:@"%2.1f%%",percentLabel];
    } else {
        _percentReader.text = @"0%";
    }
   
    [self updateBuyButton];
    [self removePageImageViews];
    [self updatePageImageViews];
}

- (void)setNightMode:(BOOL)active
{
    UIColor* backgroundColor = active ? [UIColor blackColor] : [UIColor whiteColor];
    UIColor* textColor       = active ? [UIColor whiteColor] : [UIColor blackColor];
    
    [NWSettings sharedSettings].readerTextColor = textColor;
    [NWSettings sharedSettings].readerBackgroundColor = backgroundColor;
    
    [self updateColors];
}

- (void)updateColors
{
    [self.view setBackgroundColor:[NWSettings sharedSettings].readerBackgroundColor];
    
    [_frontPage setBackgroundColor:[NWSettings sharedSettings].readerBackgroundColor];
    [_bottomPage setBackgroundColor:[NWSettings sharedSettings].readerBackgroundColor];
    
    if([Utils isDeviceiPad])
    {
        [_frontPage2 setBackgroundColor:[NWSettings sharedSettings].readerBackgroundColor];
        [_bottomPage2 setBackgroundColor:[NWSettings sharedSettings].readerBackgroundColor];
    }
  
    
    _percentReader.textColor = [NWSettings sharedSettings].readerTextColor;
    
    [_frontFB2View setNeedsDisplay];
    [_backFB2View setNeedsDisplay];
    
    if([Utils isDeviceiPad] && ![Utils isPortrait])
    {
        [_frontFB2View2 setNeedsDisplay];
        [_backFB2View2 setNeedsDisplay];
    }
}

- (void)showPanels
{
    if (_bottomPanel.alpha !=0)
        return;
    
    static NSString * const animationID = @"fadein";
    _navigationBar.alpha = 0.0;
    _bottomPanel.alpha = 0.0;
	_upperPanel.alpha = 0.0;
    [UIView beginAnimations:animationID context:nil];
    [UIView setAnimationDuration:0.2];    
    _navigationBar.alpha = 1.0;   
    _bottomPanel.alpha = 1.0;
	_upperPanel.alpha = 1.0;
    [self.view bringSubviewToFront:_navigationBar];
    [self.view bringSubviewToFront:_bottomPanel];
	[self.view bringSubviewToFront:_upperPanel];
    _visibleMenu = YES;
    [UIView commitAnimations];
}

- (void)hidePanels
{
    if (_bottomPanel.alpha != 1.0)
        return;
    
    static NSString * const animationID = @"fadeout";
    _visibleMenu = NO;
    
    _navigationBar.alpha = 1.0;
    _bottomPanel.alpha = 1.0;
	_upperPanel.alpha = 1.0;
    
    [UIView beginAnimations:animationID context:nil];
    [UIView setAnimationDuration:0.2];    
    _navigationBar.alpha = 0.0;
    _bottomPanel.alpha = 0.0;
    _upperPanel.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)showBlackLayout
{
    _fadeView.alpha = 1.0;
    [_fadeView setHidden:NO];
}

- (void)fadeOutLayout
{
    _fadeView.alpha = 1.0;
    static NSString * const fadeAnimation = @"FadeAnimation";
    [UIView beginAnimations:fadeAnimation context:nil];    
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelegate:self];
    
    _fadeView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{    
    [self hidePanels];
}

- (void)unzipFile:(NSString*)path needDeleteSource:(BOOL)needDelete
{   
    ZipFile*  zip = [[ZipFile alloc] initWithFileName:path mode:ZipFileModeUnzip];       
    FileInZipInfo* info = zip.getCurrentFileInZipInfo;
    [zip release];
    
    if (info) {
        float fileInZipSize = info.size;
        
        if (fileInZipSize > ([Utils getFreeSpace]+1024*4)) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_SPACE_ERROR_MSG", @"")];
            return;
        }
    }
    
    UnzipOperation* operation = [[UnzipOperation alloc] initWithPath:path];
    operation.delegate = self;
    operation.needDeleteSource = needDelete;
    [_operationQueue addOperation:operation];
    [operation release];
}

- (void)decodeFile:(NSString*)path
{
    DecodeOperation* operation = [[DecodeOperation alloc]   initWithPath:path salt:[NSString stringWithFormat:@"%d", _bookCacheItem.bookCard.ID]];
    operation.delegate = self;
    [_operationQueue addOperation:operation];
    [operation release];
}

- (BOOL)isFileZip:(NSString*)path
{
    BOOL result = YES;
    ZipFile* zip = nil;
    @try
    {
        zip = [[ZipFile alloc] initWithFileName:path mode:ZipFileModeUnzip];        
        [zip release];
    }
    @catch (NSException* exception) {
        result = NO;
    }
    return result;
}

- (void)updateCurrentPage
{
    [_bookSlider setMaximumValue:_currentPagesGenerator.pagesCount - 1];
    NSLog(@"pages count: %i", _currentPagesGenerator.pagesCount);
    int newPageIdx = [_currentPagesGenerator pageIndexForFB2ItemID:_itemID offset:_offset];
    if (newPageIdx == -1) newPageIdx = 0;

    self.currentPage = newPageIdx;

    [self showCurrentPage];
    [self updateChapterOffsets];
    [self updateBookmarkOffsets];
    [self updateBookmarksCountForChapters];

    [self removePageImageViews];
    [self updatePageImageViews];
}

- (void)generateBookPages
{
    if (!_fb2File)
        return;
    
    _currentPagesGenerator = (UIInterfaceOrientationIsPortrait(self.statusBarOrientation)) ? _portraitPagesGenerator : _landscapePagesGenerator;
    [_frontFB2View initializeWithPageGenerator:_currentPagesGenerator];
    [_backFB2View initializeWithPageGenerator:_currentPagesGenerator];
    
    if([Utils isDeviceiPad]){
        [_frontFB2View2 initializeWithPageGenerator:_currentPagesGenerator];
        [_backFB2View2 initializeWithPageGenerator:_currentPagesGenerator];
    }
    
    
    if (_currentPagesGenerator.pagesCount == 0 && !_currentPagesGenerator.generatingPages)
    {
        if (![SVProgressHUD isVisible])
            [SVProgressHUD showWithStatus:NSLocalizedString(@"IDS_PLEASE_WAIT", @"")];
        
        _bookSlider.userInteractionEnabled = NO;
        [_currentPagesGenerator generatePagesWithFB2:_fb2File
                                            pageSize:_frontFB2View.pageSize
                                            delegate:self];
    } else {
        [self updateCurrentPage];
    }
}

- (BOOL)bookFileIsIncorrect:(NSString*)path
{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSError* err = nil;
    unsigned long long fileSz = [[manager attributesOfFileSystemForPath:path error:&err] fileSize];
    
    if (fileSz < MIN_ZIP_FILE_SIZE) {
        return YES;
    }
    
    return NO;
}

#pragma mark FB2ViewDelegate

- (void)pageGeneratingFinished
{
    [SVProgressHUD dismiss];
    _bookSlider.userInteractionEnabled = YES;
    [_frontFB2View initializeWithPageGenerator:_currentPagesGenerator];
    [_backFB2View initializeWithPageGenerator:_currentPagesGenerator];
    
    if([Utils isDeviceiPad] && ![Utils isPortrait]){
        [_frontFB2View2 initializeWithPageGenerator:_currentPagesGenerator];
        [_backFB2View2 initializeWithPageGenerator:_currentPagesGenerator];
    }

    //if first run
    if (_isFirstRun && (_bookCacheItem.positionBookmark)) {
        _offset = _bookCacheItem.positionBookmark.offset;
        _itemID = _bookCacheItem.positionBookmark.fb2ItemID;
    }
    
    [self updateCurrentPage];

    _isFirstRun = NO;
}

#pragma mark FontSettings delegate

- (void)fontSettingsViewControllerWillDismiss:(FontSettingsViewController *)vc fontSettingsModified:(BOOL)fontSettingsChanged textColorModified:(BOOL)textColorChanged
{
    if (fontSettingsChanged)
    {
        [_portraitPagesGenerator clear];
        [_landscapePagesGenerator clear];
        
        [self generateBookPages];
    }
}

- (IBAction)incrementButtonTouched:(id)sender
{
    if ([NWSettings sharedSettings].readerFontSize < MAX_FONT_SIZE)
    {
        [NWSettings sharedSettings].readerFontSize++;
        //[self updateTextExample];
		
		[_portraitPagesGenerator clear];
        [_landscapePagesGenerator clear];
		
		[self generateBookPages];
    }
}

- (IBAction)decrementButtonTouched:(id)sender
{
	if ([NWSettings sharedSettings].readerFontSize > MIN_FONT_SIZE)
	{
		[NWSettings sharedSettings].readerFontSize--;
		//[self updateTextExample];
		
		[_portraitPagesGenerator clear];
        [_landscapePagesGenerator clear];
		
		[self generateBookPages];
	}
}

#pragma mark DecodeOperation delegate

- (void)decodeOperationFinishedWithData:(NSData *)decodedData
{
    if (!decodedData || [decodedData length]==0)
    {
        [self performSelectorOnMainThread:@selector(decodeOperationFailed)
                               withObject:nil
                            waitUntilDone:NO ];
        return;
    }    
    NSString * path = [[Utils tempDirectoryPath] stringByAppendingPathComponent:[Utils uniqueString]];    
    [decodedData writeToFile:path atomically:YES];
    [self unzipFile:path needDeleteSource:YES];
}

- (void)decodeOperationFailed
{
    if ([self bookFileIsIncorrect:_bookCacheItem.localPath]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_BOOK_IS_NON_EXISTS", @"")];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_CANT_OPEN_BOOK", @"")];
    }
           
    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
}

#pragma mark Unzip delegate

- (void)unzipOperationFinished:(UnzipOperation *)operation  withData:(NSData *)unzippedData
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        if (!unzippedData || unzippedData.length ==0 || !operation)
        {
            [self unzipOperationFailed:operation];
            return;
        }
        if (operation.needDeleteSource)
        {
            NSError* error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:operation.zipFilepath error:&error];
        }

        if ([_bookCacheItem.bookCard.fileType isEqualToString:@"pdf"]) {
            NSString* password = nil;
            NSString* filePath = _bookCacheItem.localPath;
            [unzippedData writeToFile:[filePath stringByAppendingString:@".pdf"] atomically:YES];
            ReaderDocument*  document = [[[ReaderDocument alloc] initWithFilePath:[filePath stringByAppendingString:@".pdf"] password:password] autorelease];

            if (document == nil) {
                NSLog(@"Invalid pdf file : %@", filePath);
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ERROR: LOADED PDF FILE IS INVALID", @"ERROR: LOADED PDF FILE IS INVALID")];
                return;
            }
            [SVProgressHUD dismiss];
            [self showPDFViewerWithDocument:document];

        } else {
            [self openFB2FromData:unzippedData];
        }
    });
}

- (void)showPDFViewerWithDocument:(ReaderDocument*)document
{
    ReaderViewController* pdfVC = [[[ReaderViewController alloc] initWithReaderDocument:document] autorelease];
    pdfVC.delegate = self;
    pdfVC.bookCacheItem = _bookCacheItem;
    UINavigationController* navi = [[[UINavigationController alloc] initWithRootViewController:pdfVC] autorelease];
    [self presentModalViewController:navi animated:NO];
}

- (void)unzipOperationFailed:(UnzipOperation *)operation
{
    if (!operation)
        return;    
    if (operation.needDeleteSource)
    {
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:operation.zipFilepath error:&error];
    }
    
    if ([self bookFileIsIncorrect:operation.zipFilepath]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_BOOK_IS_NON_EXISTS", @"")];
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_CANT_OPEN_BOOK", @"")];
    }

    [self performSelectorOnMainThread:@selector(closeView) withObject:nil waitUntilDone:NO];
}

#pragma mark BookContentViewcontrollerDelegate

- (void)contentItemSelected:(NWBookContentItem *)item
{
    int pageIndex = [_currentPagesGenerator pageIndexForFB2ItemID:item.titleID offset:item.offset];
    if (pageIndex == -1)
        return;

    self.currentPage = pageIndex;
    [self hideReturnButton];
}

#pragma mark BookmarkViewcontrollerDelegate methods

- (void)bookmarkItemSelected:(NWBookmarkItem *)item
{    
    int pageIndex = [_currentPagesGenerator pageIndexForFB2ItemID:item.fb2ItemID offset:item.offset];
    
    if (pageIndex == -1)
        return;

    self.currentPage = pageIndex;
    [self hideReturnButton];
}

- (void)bookmarkItemDeleted
{
  [self updateBookmarksCountForChapters];
}

#pragma mark Touch Events

#pragma mark NWApiClientDelegate methods

- (void)apiClientPurchaseResult:(BOOL)purchase bookID:(int)bookID
{
    if (purchase)
    {
        [SVProgressHUD dismiss];
        [self notifySuccessfullyPurchaseBookWithID:bookID];
        [[NWApiClient sharedClient] getURLOfFullVersionBookWithID:bookID delegate:self];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"IDS_ERROR_PURCHASE_BOOK", @"")];
    }
}

- (void)apiClientReceivedFullVersionURL:(NSString*)bookURL
{
    NSString* destinationPath = [[Utils cacheDirectoryPath] stringByAppendingPathComponent:PurchasedBooksFolder];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    destinationPath = [destinationPath stringByAppendingPathComponent:[Utils uniqueString]];
    [self loadBook:_bookCacheItem.bookCard URL:bookURL toPath:destinationPath cache:[NWDataModel sharedModel].purchasedBooksCache];
}

- (void)apiClientDidFailedExecuteMethod:(NSString*)methodName error:(NSError*)error
{
    [SVProgressHUD dismiss];
}

#pragma mark ASMediasFocusDelegate implementation

- (UIImage *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager imageForView:(UIView *)view
{
    [self hidePanels];
    return ((UIImageView *)view).image;
}

- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager finalFrameforView:(UIView *)view
{
    return self.view.bounds;
}

- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager
{
    return self;
}

- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager startFrameforView:(UIView *)view
{
    for(UIView* subView in _frontFB2View.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            if (subView.tag == view.tag)
            {
                
                return [_frontFB2View convertRect:subView.frame toView:_frontFB2View.superview];
            }
        }
    }
    
    for(UIView* subView in _frontFB2View2.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            if (subView.tag == view.tag)
            {
                
                return [_frontFB2View2 convertRect:subView.frame toView:_frontFB2View2.superview];
            }
        }
    }
    
    return CGRectZero;
}

- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaPathForView:(UIView *)view
{
    return nil;
}

#pragma mark ReaderViewController delegate

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
     [self dismissModalViewControllerAnimated:NO];
//    [self onBackButton:self];
}

@end
