//
//  FB2SectionGenerator.m
//  NewspaperWorld
//
//  Created by Эльдар Пикунов on 08.04.13.
//
//

#import "FB2SectionGenerator.h"
#import "FB2PageGeneratorContext.h"
#import "FB2Section.h"

@implementation FB2SectionGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    if (![item isKindOfClass:[FB2Section class]])
        return;
    
    FB2Section* section = (FB2Section*)item;

    for(FB2Section* subsection in section.subSections) {
        [subsection.title setNesting:[section.title getNesting]+1];
    }
    
    BOOL sectionIDAdded = NO;
    for (FB2Item* child in section.subItems)
    {
        if (!context.page)
            context.page = [FB2PageData pageData];
        
        [child generatePagesWithContext:context parentStyle:nil];

        if (!sectionIDAdded && section.ID.length > 0)
        {
            [context.page.nodeIDs addObject:[section ID]];
            sectionIDAdded = YES;
        }
    }
}

@end
