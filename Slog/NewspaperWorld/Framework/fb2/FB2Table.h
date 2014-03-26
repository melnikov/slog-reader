//
//  FB2Table.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2Table : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
