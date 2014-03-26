//
//  Constants.h
//  NewspaperWorld
//

#ifndef NewspaperWorld_Constants_h
#define NewspaperWorld_Constants_h

//Notifications
#define SEARCH_SHOULDSHOW_NOTIFICATION      @"SearchTouched"
#define HELP_SHOULDSHOW_NOTIFICATION        @"HelpTouched"
#define CATEGORY_SHOULDSHOW_NOTIFICATION    @"CategoryShow"
#define BOOKLIST_SHOULDSHOW_NOTIFICATION    @"BookListShow"
#define LAST_READED_SHOULDSHOW_NOTIFICATION @"LastReadedShow"
#define FRAGMENTS_SHOULDSHOW_NOTIFICATION   @"FragmentsShow"
#define MY_BOOKS_SHOULDSHOW_NOTIFICATION    @"MyBooksShow"
#define BOOK_PURCHASED_NOTIFICATION         @"BookPurchased"

static NSString* const PurchasedBooksFolder = @"purchased_books";
static NSString* const DemoFragmentsFolder  = @"demo_fragments";

// defaults
#define UI_RED_COLOR ([UIColor colorWithRed:0.702495 green:0 blue:0 alpha:1.0])
#define UI_YELLOW_COLOR ([UIColor colorWithRed:0.98 green:0.93 blue:0.71 alpha:1.0])

#define TEST_MODE 0

#endif
