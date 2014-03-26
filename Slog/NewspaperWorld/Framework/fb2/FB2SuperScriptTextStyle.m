//
//  FB2SuperiorTextStyle.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2SuperScriptTextStyle.h"
#import "NWSettings.h"

static const float REFERENCE_FONT_DECREATOR = 0.8;
static const CGFloat REF_VERTICAL_SLIDE = 0.2;

@implementation FB2SuperScriptTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        _verticalOffset = _textFont.lineHeight*REF_VERTICAL_SLIDE;
        [self applyFontSize:[NWSettings sharedSettings].readerFontSize*REFERENCE_FONT_DECREATOR];        
        _isDefault = NO;
        
        FB2TextStyle* style = [[[FB2TextStyle alloc] init] autorelease];
        _lineHeight = style.lineHeight;
    }
    return self;
}

@end
