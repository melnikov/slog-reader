//
//  FB2Style.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2Style : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
