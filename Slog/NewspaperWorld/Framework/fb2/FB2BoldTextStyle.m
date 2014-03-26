//
//  FB2BoldTextStyle.m
//  NewspaperWorld
//

#import "FB2BoldTextStyle.h"
#import "NWSettings.h"

@implementation FB2BoldTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self applyTextFontFamily:[NWSettings sharedSettings].readerBoldFontFamily];
        _isDefault = NO;
    }
    return self;
}

@end
