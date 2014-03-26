//
//  FB2FormattedTextItemFactory.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "FB2Item.h"
#import "GDataXMLNode.h"

@interface FB2ItemFactory : NSObject

+ (id)itemFromXMLElement:(GDataXMLElement*)element;

@end
