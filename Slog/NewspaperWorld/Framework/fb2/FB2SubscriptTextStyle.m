//
//  FB2SubscriptTextStyle.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2SubscriptTextStyle.h"
#import "NWSettings.h"

static const float REFERENCE_FONT_DECREATOR = 0.8;
static const CGFloat REF_VERTICAL_SLIDE = 0.2;

@implementation FB2SubscriptTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        _verticalOffset = -2*_textFont.lineHeight*REF_VERTICAL_SLIDE;
        [self applyFontSize:[NWSettings sharedSettings].readerFontSize*REFERENCE_FONT_DECREATOR];
        _isDefault = NO;
    }
    return self;
}

- (CGFloat)lineHeight
{
    FB2TextStyle* style = [[[FB2TextStyle alloc] init] autorelease];
    return style.lineHeight;
}

@end
