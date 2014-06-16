//
//  ExpandableView.m
//  NewspaperWorld
//


#import "ExpandableView.h"

const static int defaultButtonHeight = 60;

@interface  ExpandableView()

- (void)initClass;

- (void)initExpandButton;

- (void)layoutSubviews;

- (void)updateViewsPositions;

- (IBAction)expandTouched:(id)sender;

- (void)updateIndicator;

@end

@implementation ExpandableView

@synthesize expandButtonHeight   = _expandButtonHeight;
@synthesize expandHeight         = _expandHeight;
@synthesize isExpanded           = _isExpanded;
@synthesize childView            = _childView;
@synthesize delegate             = _delegate;
@synthesize expandIndicatorImage = _expandImage;
@synthesize rollupIndicatorImage = _rollupImage;

#pragma mark Memory management

- (void)initClass
{    
    _expandButton       = nil;
    _expandButtonHeight = defaultButtonHeight;
    _expandHeight  = 0;
    _isExpanded = NO;
    _child = nil;
    _delegate = nil; 
    _rollupImage = nil;
    _expandImage = nil;
    
    [self initExpandButton];
}

- (id)initWithFrame:(CGRect)frame
{
    
    if (frame.size.height == 0)
    {
        frame.size.height = _expandButtonHeight;
    }
    self = [super initWithFrame:frame];    
    if (self)
    {
        [self initClass];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self initClass];
    }
    return self;
}

- (void)dealloc
{
    [_expandImage release];
    [_rollupImage release];   
    [_expandButton release];
    [_child release];
    [super dealloc];
}

#pragma mark View life cycle

- (void)awakeFromNib
{    
    [super awakeFromNib];
    [self initExpandButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateViewsPositions];
}

#pragma mark Private implementation

- (void)initExpandButton
{       
    if (!_expandButton)
    {
        _expandButton = [[UIButton alloc] init];
        [self addSubview:_expandButton];
    }
	
	//_expandButton.titleLabel.font = [UIFont systemFontOfSize:20];
	
	_expandButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	_expandButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
    [_expandButton setTitleColor:RGB(180, 6, 16) forState:UIControlStateNormal];
    [_expandButton setTitleColor:RGB(180, 6, 16) forState:UIControlStateHighlighted];
    [_expandButton setTitleColor:RGB(180, 6, 16) forState:UIControlStateSelected];
    
    
    [_expandButton removeTarget:self action:@selector(expandTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_expandButton addTarget:self action:@selector(expandTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_expandButton setFrame:CGRectMake(40, 0, _expandButton.frame.size.width, _expandButtonHeight)];
       
    [self updateIndicator];
}

- (void)setButtonBackgroundImage:(UIImage*)image forState:(UIControlState)state
{
    //[_expandButton setBackgroundImage:image forState:state];
}

- (void)setButtonTitle:(NSString*)text
{
	text = [text uppercaseString];
	
    [_expandButton setTitle:text forState:UIControlStateNormal];
    [_expandButton setTitle:text forState:UIControlStateSelected];
    [_expandButton setTitle:text forState:UIControlStateHighlighted];    
}

- (void)expand:(BOOL)needExpand
{
    if (_isExpanded != needExpand)
    {
        _isExpanded = needExpand;
        
        [self updateViewsPositions];        
        [self updateIndicator];
    }
}

- (IBAction)expandTouched:(id)sender
{
    if ([_delegate respondsToSelector:@selector(expandableViewShouldExpand:)] || _delegate == nil)
    {
        if ([_delegate expandableViewShouldExpand:self] || _delegate == nil)
        {
            [UIView beginAnimations:@"ExpandAnimation" context:nil];
            [UIView setAnimationDuration:EXPAND_ANIMATION_DURATION];
            [UIView setAnimationDelay:EXPAND_ANIMATION_DELAY];
            [UIView setAnimationBeginsFromCurrentState:YES];
    
            [self expand:!_isExpanded];
        
            if (_delegate && [_delegate respondsToSelector:@selector(expandButtonTouched:)])
                [_delegate expandButtonTouched:self];
        
            [UIView commitAnimations];
        }
    }
}

- (void)setExpandButtonHeight:(int)newHeight
{
    _expandButtonHeight = newHeight;
    [self initExpandButton];
    [self updateViewsPositions];
}

- (void)setExpandHeight:(int)newHeight
{
    _expandHeight = newHeight;
    if (_expandHeight < self.bounds.size.height - _expandButtonHeight || _isExpanded)
    {
        CGRect newFrame = self.frame;
        newFrame.size.height = _expandButtonHeight + _expandHeight;
        [self setFrame:newFrame];
    }
}

- (void)updateViewsPositions
{
    int newHeight = _isExpanded ? _expandButtonHeight + _expandHeight : _expandButtonHeight;
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    [self setFrame:newFrame];
    if (_expandButton)
    {
        [_expandButton setFrame:CGRectMake(40, 0, _expandButton.frame.size.width, _expandButtonHeight)];
        [_expandButton setSelected:_isExpanded];
    }
    if (_child)
    {
        [_child setFrame:CGRectMake(0, _expandButtonHeight, self.bounds.size.width, self.bounds.size.height - _expandButtonHeight)];
    }    
}

- (void)updateIndicator
{
//    [_expandButton setBackgroundImage:_isExpanded ? _rollupImage: _expandImage  forState:UIControlStateNormal];
//    [_expandButton setBackgroundImage:_isExpanded ? _rollupImage: _expandImage  forState:UIControlStateHighlighted];
//    [_expandButton setBackgroundImage:_isExpanded ? _rollupImage: _expandImage  forState:UIControlStateSelected];
}

#pragma mark Public methods

- (void)setChildView:(UIView*)child
{
    if (child == nil)
    {
        [_child release];
        [_child removeFromSuperview];
        _child = nil;
        return;
    }
   
    [child removeFromSuperview];
    [self addSubview:child];
    
    [_child release];
    _child = [child retain];
    
    [self updateViewsPositions];
}

- (void)setExpandIndicatorImage:(UIImage*)newImage
{
    if (newImage == _expandImage)
        return;
    
    [_expandImage release];
    _expandImage = [newImage retain];
    [self updateIndicator];
}

- (void)setRollupIndicatorImage:(UIImage*)newImage
{
    if (_rollupImage == newImage)
        return;
    
    [_rollupImage release];
    _rollupImage = [newImage retain];
    [self updateIndicator];
}

@end
