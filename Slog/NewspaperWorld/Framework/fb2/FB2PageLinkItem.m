//
//  FB2PageLinkItem.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 26.03.13.
//
//

#import "FB2PageLinkItem.h"
#import "FB2Link.h"

@interface FB2PageLinkItem()

@property (nonatomic, readonly) FB2Link* link;
@end

@implementation FB2PageLinkItem

+ (FB2PageLinkItem*)itemWithLink:(FB2Link*)link frameRect:(CGRect)aFrame
{
    return [[[FB2PageLinkItem alloc] initWithLink:link
                                        frameRect:aFrame] autorelease];
}

- (id)initWithLink:(FB2Link*)link
         frameRect:(CGRect)aFrame
{
    if (!link)
    {
        [self release];
        return nil;
    }
    return [super initWithData:link frameRect:aFrame fb2ItemID:link.itemID];
}

#pragma mark Property accessors

- (FB2Link*)link
{
    return (FB2Link*)self.data;
}

- (BOOL)isLocal
{
    return self.link.isLocal;
}

- (NSString*)href
{
    return self.link.href;
}

- (NSString*)type
{
    return self.link.type;
}
@end
