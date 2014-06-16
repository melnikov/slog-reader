//
//  BookCategoryCell.m
//  NewspaperWorld
//

#import "BookCategoryCell.h"

@interface BookCategoryCell()

- (void)animateAccessory;

@end

@implementation BookCategoryCell

@synthesize title;
@synthesize showTopSeparator;
@synthesize showBottomSeparator;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {     
        _titleLabel = nil;
        _bottomSeparator = nil;
        _topSeparator = nil;
    }
    return self;
}

- (void)dealloc
{
    [_titleLabel release];
    [_bottomSeparator release];
    [_topSeparator release];
    [super dealloc];
}

- (void)awakeFromNib
{    
    [super awakeFromNib];    
    self.showTopSeparator = YES;
    self.showBottomSeparator = NO;
    [_titleLabel setHighlightedTextColor:[UIColor blackColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:YES];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
  if (highlighted)
  {
    [self animateAccessory];
  }
  [super setSelected:highlighted animated:YES];
}
#pragma mark Private

- (void)animateAccessory
{
  NSTimeInterval animationDuration = 0.3;
  
  NSString* zoomInID = @"zoomInID";
  [UIView beginAnimations:zoomInID context:nil];
  [UIView setAnimationDuration:animationDuration];

  self.accessoryView.transform = CGAffineTransformMakeScale(0.8, 0.8);
  [UIView commitAnimations];
  
  NSString* zoomOutID = @"zoomOutID";
  [UIView beginAnimations:zoomOutID context:nil];
  [UIView setAnimationDuration:animationDuration];
  self.accessoryView.transform = CGAffineTransformMakeScale(1.0, 1.0);
  [UIView commitAnimations];
}

#pragma mark Public methods

+ (NSString*)reuseIdentifier
{
    return @"BookCategoryCellID";
}

+ (NSString*)nibName
{
    return @"BookCategoryCell";
}
#pragma mark Property accessors

- (void)setTitle:(NSString*)newTitle
{
    [_titleLabel setText:newTitle];
}

- (NSString*)title
{
    return _titleLabel.text;
}

-(UILabel*)textLabel
{
	return _titleLabel;
}

- (void)setShowTopSeparator:(BOOL)newValue
{
    //[_topSeparator setHidden:!newValue];
}

- (void)setShowBottomSeparator:(BOOL)newValue
{
//    [_bottomSeparator setHidden:!newValue];
}

- (BOOL)showBottomSeparator
{
    return [_bottomSeparator isHidden]; 
}

- (BOOL)showTopSeparator
{
    return [_topSeparator isHidden];
}
@end
