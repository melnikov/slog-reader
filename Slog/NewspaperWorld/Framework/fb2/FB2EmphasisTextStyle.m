//
//  FB2EmphasisTextStyle.m
//  NewspaperWorld
//

#import "FB2EmphasisTextStyle.h"
#import "NWSettings.h"

@implementation FB2EmphasisTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self applyTextFontFamily:[NWSettings sharedSettings].readerItalicFontFamily];
        _isDefault = NO;
    }
    return self;
}

@end
