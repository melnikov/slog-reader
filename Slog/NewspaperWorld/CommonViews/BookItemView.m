//
//  BookItemView.m
//  NewspaperWorld
//

#import "BookItemView.h"
#import "UIImageView+AFNetworking.h"
#import "NWDataModel.h"

@interface BookItemView ()

- (void)initializeDefault;

- (void)updateLabelsLayout;

- (void)autosizeLabel:(UILabel*)label;

@end

@implementation BookItemView

@synthesize bookAuthors     = _bookAuthors;
@synthesize bookTitle       = _bookTitle;
@synthesize bookCoverURL    = _bookCoverURL;
@synthesize bookDuration    = _bookDuration;
@synthesize bookPrice       = _bookPrice;
@synthesize bookID          = _bookID;
@synthesize bookIsSold      = _bookIsSold;
@synthesize delegate        = _delegate;
@synthesize showsDeleteButton = _showsDeleteButton;
@synthesize bookCoverView;
@synthesize buyButton;

#pragma mark Memory managment

- (id)initWithFrame:(CGRect)frame
{
    [self initializeDefault];
    
    self = [super initWithFrame:frame];
    return self;
}

- (void)dealloc
{
    [_bookCoverView     release];
    [_bookAuthorsView   release];
    [_bookTitleView     release];
    [_bookDurationView  release];
    [_buyButton         release];
    [_itemButton        release];
    
    [_bookAuthors    release];
    [_bookTitle      release];
    [_bookCoverURL   release];
    [_bookDuration   release];
    [_bookPrice      release];
  
    _delegate = nil;
    
    [super dealloc];
}

#pragma mark View life cycle

- (void)layoutSubviews
{
	if(self.bookCoverViewMirror && CGAffineTransformEqualToTransform(self.bookCoverViewMirror.transform, CGAffineTransformIdentity))
	{
		self.bookCoverViewMirror.transform = CGAffineTransformMakeScale(1.0, -1.0);//CGAffineTransformRotate(self.bookCoverViewMirror.transform, 3.14);
	}
	
    [self autosizeLabel:_bookAuthorsView];
    [self autosizeLabel:_bookTitleView];
    [self autosizeLabel:_bookDurationView];
    [self updateLabelsLayout];
    [super layoutSubviews];
}
#pragma mark Private implementation

- (void)initializeDefault
{
    _bookAuthors    = nil;
    _bookTitle      = nil;
    _bookCoverURL   = nil;
    _bookDuration   = nil;
    _bookPrice      = nil;
    _bookID         = -1;
    _bookIsSold = NO;
    _showsDeleteButton = NO;
    
    _itemButton         = nil;
    _bookCoverView      = nil;
    _bookAuthorsView    = nil;
    _bookTitleView      = nil;
    _bookDurationView   = nil;
    _buyButton          = nil;
}

- (void)autosizeLabel:(UILabel*)label
{
    //float lineHeight = label.font.pointSize + 2;
    CGSize labelSize = [label.text sizeWithFont:label.font
                              constrainedToSize:CGSizeMake(label.frame.size.width, 34/*2*lineHeight*/)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    CGRect oldFrame = label.frame;
    oldFrame.size.height = (labelSize.height > 34/*2*lineHeight*/) ? 34/*2*lineHeight*/ : labelSize.height;
    [label setFrame:oldFrame];
	
    label.lineBreakMode = UILineBreakModeTailTruncation;
}

- (void)updateLabelsLayout
{
    CGRect prevFrame = _bookCoverView.frame;
    CGRect curFrame = _bookAuthorsView.frame;
   
    curFrame.origin.y = prevFrame.origin.y - curFrame.size.height - 8;
    [_bookAuthorsView setFrame:curFrame];

    prevFrame = _bookAuthorsView.frame;
    curFrame = _bookTitleView.frame;
    curFrame.origin.y = prevFrame.origin.y - curFrame.size.height - 8;
    [_bookTitleView setFrame:curFrame];

//    prevFrame = _bookTitleView.frame;
//    curFrame = _bookDurationView.frame;
//    curFrame.origin.y = prevFrame.origin.y + prevFrame.size.height;
//    [_bookDurationView setFrame:curFrame];
}

#pragma mark Property accessors

- (UIImageView*)bookCoverView
{
    return _bookCoverView;
}

- (UIButton*)buyButton
{
    return _buyButton;
}

- (void)setBookAuthors:(NSString*)newAuthors
{
    [_bookAuthorsView setText:newAuthors];
    [self autosizeLabel:_bookAuthorsView];

    [_bookAuthors release];
    _bookAuthors = [[NSString alloc] initWithString:newAuthors];

    [self updateLabelsLayout];
}

- (void)setBookTitle:(NSString*)newTitle
{
    [_bookTitleView setText:newTitle];
    [self autosizeLabel:_bookTitleView];
    
    [_bookTitle release];
    _bookTitle = [[NSString alloc] initWithString:newTitle];
    
    [self updateLabelsLayout];
}

- (void)setBookCoverURL:(NSString*)newCover
{
    [_bookCoverURL release];
    _bookCoverURL = [newCover retain];

    NSURL* coverURL = [NSURL URLWithString:_bookCoverURL];
    NWBookCacheItem* item = [[NWDataModel sharedModel] cacheItemWithBookID:_bookID];
   
    if (item.image) {
        [_bookCoverView setImage:item.image];
		
		if(self.bookCoverViewMirror)
		{
			self.bookCoverViewMirror.image = [self maskImage:item.image withMask:[UIImage imageNamed:@"mask_item.png"]];
		}
		
    } else {
        [_bookCoverView setImageWithURLRequest:[NSURLRequest requestWithURL:coverURL] placeholderImage:[UIImage imageNamed:@"default_item.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

            
            NWBookCacheItem* item_tmp = [[NWDataModel sharedModel] cacheItemWithBookID:_bookID];

            if (item_tmp) {
                item_tmp.image = _bookCoverView.image;
				
				if(self.bookCoverViewMirror)
				{
					self.bookCoverViewMirror.image = [self maskImage:item_tmp.image withMask:[UIImage imageNamed:@"mask_item.png"]];
				}
            }
			else
			{
				if(self.bookCoverViewMirror)
				{
					self.bookCoverViewMirror.image = [self maskImage:_bookCoverView.image withMask:[UIImage imageNamed:@"mask_item.png"]];
				}
			}
        } failure:nil];
    }
    [self updateLabelsLayout];
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	
    CGImageRef maskRef = maskImage.CGImage;
	
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
	
}

- (void)setBookDuration:(NSString*)newDuration
{
    [_bookDurationView setText:newDuration];
    [self autosizeLabel:_bookDurationView];
    
    [_bookDuration release];
    _bookDuration = [[NSString alloc] initWithString:newDuration];

    [self updateLabelsLayout];
}

- (void)setBookPrice:(NSString*)newPrice
{
    NSString * str = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"IDS_BUY", nil), newPrice];
    [_buyButton setTitle:str forState:UIControlStateNormal];
    [_buyButton setTitle:str forState:UIControlStateHighlighted];
    [_buyButton setTitle:str forState:UIControlStateSelected];

    CGSize textSize = [str sizeWithFont:_buyButton.titleLabel.font];
    CGRect buttonFrame = _buyButton.frame;
    if(buttonFrame.size.width < textSize.width)
        buttonFrame.size.width = textSize.width;
    [_buyButton setFrame:buttonFrame];

    [_bookPrice release];
    _bookPrice = [[NSString alloc] initWithString:newPrice];
}

- (void)setBookIsSold:(BOOL)value
{
    [_buyButton setHidden:value];
}

- (void)setShowsDeleteButton:(BOOL)showsDeleteButton
{
    _showsDeleteButton = showsDeleteButton;
    
    [_deleteButton setHidden:!showsDeleteButton];
}

#pragma mark Public methods

- (IBAction)buyButtonTouched:(id)sender
{
    if ([_delegate respondsToSelector:@selector(buyButtonOnBookItemTouchedWithBookID:)])
        [_delegate buyButtonOnBookItemTouchedWithBookID:_bookID];
}

- (IBAction)deleteButtonTouched:(id)sender
{
    if ([_delegate respondsToSelector:@selector(deleteButtonOnBookItemTouchedWithBookID:)])
        [_delegate deleteButtonOnBookItemTouchedWithBookID:_bookID];
}

- (IBAction)itemTouched:(id)sender;
{
    if ([_delegate respondsToSelector:@selector(bookItemTouchedWithBookID:)])
        [_delegate bookItemTouchedWithBookID:_bookID];  
}

@end
