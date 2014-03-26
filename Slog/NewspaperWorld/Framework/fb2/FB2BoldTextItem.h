//
//  FB2BoldTextItem.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2BoldTextItem : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
