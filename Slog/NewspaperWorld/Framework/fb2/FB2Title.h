//
//  FB2Title.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "FB2TextItem.h"

@interface FB2Title : FB2TextItem
{
    CGFloat  _baseIncreaseParam;
    NSArray* _nestingSizes;
    NSUInteger  _nesting;
}

- (void)increaseNesting;
- (NSUInteger)getNesting;
- (void)setNesting:(NSUInteger)newValue;

+ (FB2Title*)itemFromXMLElement:(GDataXMLElement*)element;

@end
