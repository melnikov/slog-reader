//
//  FB2SubtitleTextStyle.m
//  NewspaperWorld
//

#import "FB2SubtitleTextStyle.h"
#import "NWSettings.h"

@implementation FB2SubtitleTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self applyTextFontFamily:[NWSettings sharedSettings].readerBoldFontFamily];
        _textAlignment = NSTextAlignmentCenter;
        _isDefault = NO;
        self.textType = TEXTTYPE_EPIGRAPH;
    }
    return self;
}

@end
