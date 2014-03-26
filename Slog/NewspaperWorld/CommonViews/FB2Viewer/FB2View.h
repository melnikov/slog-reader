//
//  FB2View.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "FB2File.h"
#import "FB2PagesGenerator.h"

@interface FB2View : UIView
{
@private
    
    FB2PagesGenerator*        _pageGenerator;
    
    int             _pageWidth;    
    int             _pageHeight;
}

- (void)initializeWithPageGenerator:(FB2PagesGenerator*)generator;

@property (nonatomic, assign) int visiblePagesCount;

@property (nonatomic, assign) int currentPage;

@property (nonatomic, assign) int pageMargin;

@property (nonatomic, readonly) CGSize  pageSize;

@end
