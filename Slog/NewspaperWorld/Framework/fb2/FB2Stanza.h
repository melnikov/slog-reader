//
//  FB2Stanza.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2Stanza : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
