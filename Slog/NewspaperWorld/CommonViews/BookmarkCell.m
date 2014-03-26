//
//  ContentItemCell.m
//  NewspaperWorld
//

#import "BookmarkCell.h"

@implementation BookmarkCell

@synthesize title;

@synthesize relativeOffset = _relativeOffset;

@synthesize isGrayBackground = _isGrayBackground;

#pragma mark Memory management

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        _relativeOffset = 0.0;
        _titleLabel = nil;
        _offsetLabel = nil;
        _grayView = nil;
        _isGrayBackground = NO;
    }
    return self;
}

- (void)dealloc
{
    [_titleLabel release];
    [_offsetLabel release];
    [_grayView release];
    [super dealloc];
}

#pragma mark View life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
}

#pragma mark Public methods

+ (NSString*)reuseIdentifier
{
    return @"BookmarkCellID";
}

+ (NSString*)nibName
{
    return @"BookmarkCell";
}

+ (CGFloat)cellHeight
{
    return 44;
}
#pragma mark Property accessors


- (void)setTitle:(NSString *)value
{
    [_titleLabel setText:value];
}

- (NSString*)title
{
    return _titleLabel.text;
}

- (void)setRelativeOffset:(double)value
{
    if (value != _relativeOffset)
    {
        _relativeOffset = value;
        NSString* percentString = [NSString stringWithFormat:@"%2.1f%%",value*100.0];
        [_offsetLabel setText:percentString];
    }
}

- (double)relativeOffset
{
    return _relativeOffset;
}

- (void)setIsGrayBackground:(BOOL)value
{
    if (value != _isGrayBackground)
    {
        _isGrayBackground = value;
        self.backgroundView = value ? _grayView : nil;
    }
}

- (BOOL)isGrayBackground
{
    return _isGrayBackground;
}
@end
