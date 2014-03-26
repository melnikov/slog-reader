//
//  FB2LinkGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 09.04.13.
//
//

#import "FB2LinkGenerator.h"
#import "FB2PageLinkItem.h"
#import "FB2Link.h"
#import "FB2PageGeneratorContext.h"

@implementation FB2LinkGenerator

- (void)generatePagesForItem:(FB2Item *)item withContext:(FB2PageGeneratorContext *)context parentStyle:(FB2TextStyle *)parentStyle
{
    if (![item isKindOfClass:[FB2Link class]])
        return;

    FB2Link* link = (FB2Link*)item;    
    context.linkForAdd = link;
    [super generatePagesForItem:item withContext:context parentStyle:parentStyle];
    context.linkForAdd = nil;
}

@end
