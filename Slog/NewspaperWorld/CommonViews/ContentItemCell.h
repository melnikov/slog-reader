//
//  BookmarkCell.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BookmarkCell.h"

@interface ContentItemCell : BookmarkCell
{
    int _bookmarksCount;
    
    BOOL _isChapter;
    
    IBOutlet UILabel* _bookmarksCountLabel;
    
    IBOutlet UIImageView* _bookmarkImageView;    
}

+ (NSString*)reuseIdentifier;

+ (NSString*)nibName;

+ (CGFloat)cellHeight;

@property (nonatomic, assign) int bookmarksCount;

@property (nonatomic, assign) BOOL isChapter;

@end
