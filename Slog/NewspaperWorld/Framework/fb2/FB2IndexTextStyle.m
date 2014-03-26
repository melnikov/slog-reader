//
//  FB2IndexTextStyle.m
//  NewspaperWorld
//

#import "FB2IndexTextStyle.h"
#import "NWSettings.h"

static const float REFERENCE_FONT_DECREATOR = 0.8;

@implementation FB2IndexTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self applyFontSize:[NWSettings sharedSettings].readerFontSize*REFERENCE_FONT_DECREATOR];
        _isDefault = NO;
    }
    return self;
}
@end
