//
//  BookmarkCell.m
//  NewspaperWorld
//

#import "ContentItemCell.h"

@implementation ContentItemCell

@synthesize bookmarksCount;

@synthesize isChapter;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        _bookmarksCount = 0;
        _isChapter = NO;
        _bookmarksCountLabel = nil;
        _bookmarkImageView = nil;
    }
    return self;
}

- (void)dealloc
{
    [_bookmarksCountLabel   release];
    [_bookmarkImageView     release];
    [super dealloc];
}

#pragma mark View life-cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_bookmarksCountLabel setHidden:YES];
    [_bookmarkImageView setHidden:YES];
}

#pragma mark Public methods

+ (NSString*)reuseIdentifier
{
    return @"ContentItemCellID";
}

+ (NSString*)nibName
{
    return @"ContentItemCell";
}

+ (CGFloat)cellHeight
{
    return 44;
}
#pragma mark Property accessors

- (void)setBookmarksCount:(int)value
{
    if (_bookmarksCount != value)
    {
        _bookmarksCount = value;
        [_bookmarksCountLabel setText:[NSString stringWithFormat:@"%d", value]];
        [_bookmarkImageView setHidden:(_bookmarksCount == 0)];
        [_bookmarksCountLabel setHidden:(_bookmarksCount == 0)];
        
        CGPoint newCenter = CGPointMake(_offsetLabel.center.x , (value == 0) ? self.bounds.size.height / 2.0 : self.bounds.size.height*3.0/4.0);        
        [_offsetLabel setCenter:newCenter];
        [_offsetLabel setNeedsDisplay];
    }
}

- (int)bookmarksCount
{
    return _bookmarksCount;
}

- (void)setIsChapter:(BOOL)value
{
    if (value != _isChapter)
    {
        _isChapter = value;
        CGFloat oldFontSize = _titleLabel.font.pointSize;
        UIFont* newFont = value ? [UIFont boldSystemFontOfSize:oldFontSize] : [UIFont systemFontOfSize:oldFontSize];        
        [_titleLabel setFont:newFont];
    }
}

- (BOOL)isChapter
{
    return _isChapter;
}

- (void)setRelativeOffset:(double)value
{
    if (value != _relativeOffset)
    {
        _relativeOffset = value;
        NSString* percentString = [NSString stringWithFormat:@"%d%%",(int)(value*100.0)];
        [_offsetLabel setText:percentString];    }
}
@end
