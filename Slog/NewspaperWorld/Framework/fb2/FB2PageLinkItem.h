//
//  FB2PageLinkItem.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 26.03.13.
//
//

#import "FB2PageDataItem.h"

@class FB2Link;
@interface FB2PageLinkItem : FB2PageDataItem
{
}
+ (FB2PageLinkItem*)itemWithLink:(FB2Link*)link frameRect:(CGRect)aFrame;

- (id)initWithLink:(FB2Link*)link
         frameRect:(CGRect)aFrame;

@property (nonatomic, readonly) NSString* href;
@property (nonatomic, readonly) BOOL      isLocal;
@property (nonatomic, readonly) NSString* type;

@end
