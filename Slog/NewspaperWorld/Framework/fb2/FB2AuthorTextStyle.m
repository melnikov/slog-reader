//
//  FB2AuthorTextStyle.m
//  NewspaperWorld
//

#import "FB2AuthorTextStyle.h"
#import "NWSettings.h"

@implementation FB2AuthorTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self applyTextFontFamily:[NWSettings sharedSettings].readerItalicFontFamily];
        [self changeFontSizeTo:-2.0];
        _textAlignment = NSTextAlignmentRight;
        _isDefault = NO;
        self.textType = TEXTTYPE_EPIGRAPH;
    }
    return self;
}

@end
