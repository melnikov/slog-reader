//
//  FBEmphasisTextItem.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2EmphasisTextItem : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
