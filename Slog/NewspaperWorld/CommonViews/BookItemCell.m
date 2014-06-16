//
//  BookItemCell.m
//  NewspaperWorld
//

#import "BookItemCell.h"
#import "Utils.h"

#pragma mark Private declaration

@interface BookItemCell(Private)

- (void)initializeDefault;

@end

#pragma mark Implementation

@implementation BookItemCell

@synthesize item1     = _item1;
@synthesize item2     = _item2;
@synthesize item3     = _item3;
@synthesize backgroundImage;

#pragma mark Memory managment

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    [self initializeDefault];
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    [_item1   release];
    [_item2   release];
    [_item3   release];
    [_backgroundImageView release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark Private implementation

- (void)initializeDefault
{
    [_item1 release];
    [_item2 release];
    [_item3 release];

    _item1 = nil;
    _item2 = nil;
    _item3 = nil;
}

#pragma mark Property accessors

- (void)setBackgroundImage:(UIImage *)newImage
{
    //self.backgroundView = [[[UIImageView alloc] initWithImage:newImage highlightedImage:newImage] autorelease];
	
	self.backgroundView = [[UIImageView new] autorelease];
	
	self.backgroundColor = [UIColor clearColor];
}

- (UIImage*)backgroundImage
{
    UIImageView* imageview = (UIImageView*)self.backgroundView;
    return imageview.image;
}

+ (BookItemCell*)createCell
{
    NSString* nibName = @"BookItemCell";
    if ([Utils isDeviceiPad])
    {
        nibName = [nibName stringByAppendingString:@"_iPad"];
    }
    else
    {
        nibName = [nibName stringByAppendingString:@"_iPhone"];
    }        
    return (BookItemCell*)[Utils loadViewOfClass:[BookItemCell class] FromNibNamed:nibName];
}

+ (int)cellHeight
{
    static const int iPhoneCellHeight = 320;
    static const int iPadCellHeight = 360;
    
    if ([Utils isDeviceiPad])
        return iPadCellHeight;
    return iPhoneCellHeight;
}

@end
