//
//  FB2EpigraphTextStyle.m
//  NewspaperWorld
//


#import "FB2EpigraphTextStyle.h"
#import "NWSettings.h"

@implementation FB2EpigraphTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self applyTextFontFamily:[NWSettings sharedSettings].readerItalicFontFamily];
        [self changeFontSizeTo:-2.0];
        _isDefault = NO;
        self.textType = TEXTTYPE_EPIGRAPH;
    }
    return self;
}

@end
