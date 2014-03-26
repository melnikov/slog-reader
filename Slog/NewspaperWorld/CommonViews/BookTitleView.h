//
//  BookTitleView.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>

@interface BookTitleView : UIView
{
    IBOutlet UILabel * _titleLabel;
    
    IBOutlet UILabel * _authorLabel;
}

@property (nonatomic, retain)  NSString* bookTitle;

@property (nonatomic, retain)  NSString* bookAuthor;

@end
