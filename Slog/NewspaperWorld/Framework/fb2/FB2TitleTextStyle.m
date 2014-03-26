//
//  FB2TitleTextStyle.m
//  NewspaperWorld
//

#import "FB2TitleTextStyle.h"
#import "NWSettings.h"

@implementation FB2TitleTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self applyTextFontFamily:[NWSettings sharedSettings].readerBoldFontFamily];
        //[self changeFontSizeTo:2.0];
        _textAlignment = NSTextAlignmentCenter;
        _isDefault = NO;
        self.textType = TEXTTYPE_EPIGRAPH;
    }
    return self;

}
@end
