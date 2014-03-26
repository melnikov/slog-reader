//
//  FB2LinkTextStyle.m
//  NewspaperWorld
//


#import "FB2LinkTextStyle.h"

@implementation FB2LinkTextStyle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.textColor = [UIColor blueColor];
        _isDefault = NO;
    }
    return self;
}
@end
