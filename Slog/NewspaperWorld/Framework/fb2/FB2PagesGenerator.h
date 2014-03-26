//
//  FB2Pages.h
//  NewspaperWorld
//

#import "FB2File.h"
#import "FB2PagesGeneratorDelegate.h"
#import "FB2PageData.h"
#import "FB2PageGeneratorContext.h"

@interface FB2PagesGenerator : NSObject
{    
    NSOperationQueue*   _operations;

    FB2PageGeneratorContext* _context;    
}

- (void)generatePagesWithFB2:(FB2File*)file pageSize:(CGSize)size delegate:(NSObject<FB2PagesGeneratorDelegate>*)delegate;
- (void)clear;

- (int)pageIndexForFB2ItemID:(int)ID;
- (int)pageIndexForFB2ItemID:(int)ID offset:(int)offset;

- (FB2PageData*)pageAtIndex:(int)index;

@property (nonatomic, readonly) int pagesCount;

@property (nonatomic, readonly) BOOL generatingPages;

@property (nonatomic, retain) UIColor* textColor;

@end
