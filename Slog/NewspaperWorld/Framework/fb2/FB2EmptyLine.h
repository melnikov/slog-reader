//
//  FB2EmptyLine.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2EmptyLine : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
