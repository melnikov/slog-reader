//
//  FB2EpigraphGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2EpigraphGenerator.h"
#import "FB2Epigraph.h"
#import "FB2PageGeneratorContext.h"

@implementation FB2EpigraphGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Epigraph class]])
        return;

    FB2Epigraph* epigraph = (FB2Epigraph*)item;
    epigraph.textStyle.textType = TEXTTYPE_EPIGRAPH;

    if (!epigraph.text.subItems.count)
        return;    

    for (FB2Item* subItem in epigraph.text.subItems)
    {
        [subItem generatePagesWithContext:context parentStyle:epigraph.textStyle];
    }      

    if (epigraph.textAuthor.subItems.count > 0)
    {   
        [epigraph.textAuthor generatePagesWithContext:context parentStyle:epigraph.textStyle];
    }
    [context nextStringWithLineHeight:epigraph.textStyle.textFont.lineHeight];
    if (epigraph.ID.length > 0)
        [context.page.nodeIDs addObject:epigraph.ID];
}

@end
