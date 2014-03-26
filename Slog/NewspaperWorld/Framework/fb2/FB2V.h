//
//  FB2V.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2V : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
