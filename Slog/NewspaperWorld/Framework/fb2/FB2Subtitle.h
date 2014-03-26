//
//  FB2Subtitle.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2Subtitle : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
