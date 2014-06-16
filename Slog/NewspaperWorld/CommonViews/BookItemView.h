//
//  BookItemView.h
//  NewspaperWorld
//

#import <UIKit/UIKit.h>
#import "BookItemViewDelegate.h"

@interface BookItemView : UIView
{
@private

    IBOutlet UIImageView*    _bookCoverView;
	
	IBOutlet UIImageView*    _bookCoverViewMirror;

    IBOutlet UILabel*     _bookAuthorsView;

    IBOutlet UILabel*     _bookTitleView;

    IBOutlet UILabel*     _bookDurationView;

    IBOutlet UIButton*       _buyButton;

    IBOutlet UIButton*       _deleteButton;

    IBOutlet UIButton*       _itemButton;

    NSObject<BookItemViewDelegate>* _delegate;

    NSString* _bookAuthors;

    NSString* _bookTitle;

    NSString*  _bookCoverURL;

    NSString* _bookDuration;

    NSString* _bookPrice;

    int _bookID;
}

- (IBAction)buyButtonTouched:(id)sender;

- (IBAction)deleteButtonTouched:(id)sender;

- (IBAction)itemTouched:(id)sender;

@property (nonatomic, copy)     NSString* bookAuthors;

@property (nonatomic, copy)     NSString* bookTitle;

@property (nonatomic, retain)   NSString*  bookCoverURL;

@property (nonatomic, copy)     NSString* bookDuration;

@property (nonatomic, copy)     NSString* bookPrice;

@property (nonatomic, assign)   int bookID;

@property (nonatomic, assign)   BOOL bookIsSold;

@property (nonatomic, assign)   BOOL showsDeleteButton;

@property (nonatomic, assign)  NSObject<BookItemViewDelegate>* delegate;

@property (nonatomic, readonly) UIImageView* bookCoverView;

@property (nonatomic, readonly) UIImageView* bookCoverViewMirror;

@property (nonatomic, readonly) UIButton* buyButton;

@end
