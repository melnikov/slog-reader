//
//  FB2TextStyle.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 29.03.13.
//
//

#import "FB2TextStyle.h"
#import "NWSettings.h"

@implementation FB2TextStyle

@synthesize textFont = _textFont;
@synthesize textColor = _textColor;
@synthesize textAlignment = _textAlignment;
@synthesize isDefault = _isDefault;
@synthesize verticalOffset = _verticalOffset;
@synthesize lineHeight = _lineHeight;
@synthesize isStrikeThrough = _isStrikeThrough;

- (id)init
{
    self = [self initWithFontFamily:[NWSettings sharedSettings].readerFontFamily
                               size:[NWSettings sharedSettings].readerFontSize
                              color:[NWSettings sharedSettings].readerTextColor
                          alignment:NSTextAlignmentLeft];
    _isDefault = YES;
    _verticalOffset = 0;
    _isStrikeThrough = NO;
    _textType = TEXTTYPE_DEFAULT;
    return self;
}

- (id)initWithFontFamily:(NSString*)family size:(CGFloat)size color:(UIColor*)color alignment:(NSTextAlignment)alignment
{
    self = [super init];
    if (self)
    {
        _textFont = [[UIFont fontWithName:family
                                     size:size] retain];
        _textColor      = [color retain];
        _textAlignment  = alignment;
        _lineHeight = _textFont.lineHeight; 
    }
    return self;
}

- (void)dealloc
{
    [_textFont  release];
    [_textColor release];
    [super dealloc];
}

- (void)applyTextFontFamily:(NSString*)fontFamily
{
    CGFloat oldSize = _textFont.pointSize;
    [_textFont release];
    _textFont = [[UIFont fontWithName:fontFamily size:oldSize] retain];
    _lineHeight = _textFont.lineHeight;
}

- (void)applyFontSize:(CGFloat)newFontSize
{
    NSString* oldFontName = _textFont.fontName;
   
    [_textFont release];
    _textFont = [[UIFont fontWithName:oldFontName size:newFontSize] retain];
    _lineHeight = _textFont.lineHeight;
}

- (void)changeFontSizeTo:(CGFloat)fontSizeDiff
{
    NSString* oldFontName = _textFont.fontName;
    CGFloat oldSize = _textFont.pointSize;

    [_textFont release];
    _textFont = [[UIFont fontWithName:oldFontName size:oldSize + fontSizeDiff] retain];
    _lineHeight = _textFont.lineHeight;
}

- (id)copyWithZone:(NSZone *)zone
{
    FB2TextStyle* newStyle = [[FB2TextStyle allocWithZone:zone] init];

    [newStyle->_textFont release];
    newStyle->_textFont = [self.textFont retain];

    newStyle->_textAlignment = self.textAlignment;

    [newStyle->_textColor release];
    newStyle->_textColor = [self.textColor copy];

    newStyle->_isDefault = self.isDefault;

    newStyle->_verticalOffset = self.verticalOffset;
    
    newStyle->_isStrikeThrough = self.isStrikeThrough;

    newStyle->_lineHeight = self.lineHeight;
    newStyle->_textType = self.textType;
    
    return newStyle;
}
@end
