//
//  FB2Link.h
//  NewspaperWorld
//

#import "FB2TextItem.h"

@interface FB2Link : FB2TextItem

+ (FB2Link*)itemFromXMLElement:(GDataXMLElement*)element;


@property (nonatomic, readonly) NSString*  href;
@property (nonatomic, readonly) NSString*  type;
@property (nonatomic, readonly) BOOL       isLocal;

@end
