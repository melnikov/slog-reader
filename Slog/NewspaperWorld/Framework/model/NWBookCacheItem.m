//
//  NWBookCacheItem.m
//  NewspaperWorld
//


#import "NWBookCacheItem.h"

static NSString * const NWPListKeyLocalPath = @"local_path";
static NSString * const NWPListKeyBookCard  = @"book_card";
static NSString * const NWPListKeyBookmarks = @"bookmarks";
static NSString * const NWPListKeyPosition = @"position";

static NSString * const NAME_POSTFIX = @"_cover.png";
static NSString * const COVER_FOLDER = @"covers";
const int COVER_TOTAL_COUNT_MAX = 100;

@interface NWBookCacheItem()
{
}

- (void)saveCoverImage;

- (void)loadCoverImage;

- (void)getCoverFileName;

- (int)coverFolderSize;

- (void)controlCoverFolderCountFiles;

@end

@implementation NWBookCacheItem

@synthesize bookCard  = _bookCard;
@synthesize localPath = _localPath;
@synthesize coverImagePath = _coverImagePath;
@synthesize bookContent = _bookContent;
@synthesize bookmarks = _bookmarks;
@synthesize image = _coverImage;

#pragma mark Memory Management

- (id)init
{
    self = [super init];
    if (self)
    {
        _bookCard = nil;
        _localPath = nil;
        _bookContent = [[NWBookContent alloc] init];
        _bookmarks   = [[NWBookmarks alloc] init];
        _coverImage = nil;
        _coverImagePath = nil;
    }
    return self;
}

- (id)initWithBookCard:(NWBookCard*)bookCard localFileName:(NSString*)fileName
{
    self = [self init];
    if (self)
    {
        _bookCard  = [bookCard retain];
        _localPath = [fileName copy];
        [self getCoverFileName];
    }
   return self;
}

- (void)dealloc
{
    [_bookCard release];
    [_bookContent release];
    [_localPath release];
    [_bookmarks release];
    [_coverImage release];
    [_coverImagePath release];
    [_positionBookmark release];

    [super dealloc];
}

#pragma mark Public methods

- (BOOL)loadFromDictionary:(NSDictionary*)dictionary
{
    if ([[dictionary allKeys] indexOfObject:NWPListKeyLocalPath] == NSNotFound)
    {
        return NO;
    }
    [_localPath release];
    _localPath = [[dictionary objectForKey:NWPListKeyLocalPath] retain];

    if ([[dictionary allKeys] indexOfObject:NWPListKeyBookCard] == NSNotFound)
    {
        [_localPath release]; _localPath = nil;
        return NO;
    }
    [_bookCard release];
    _bookCard = [[NWBookCard bookFromResponseData:[dictionary objectForKey:NWPListKeyBookCard]] retain];

    [_bookmarks loadFromArray:[dictionary objectForKey:NWPListKeyBookmarks]];
    [self loadCoverImage];
    
    [_positionBookmark release];
    _positionBookmark = [[NWBookmarkItem alloc] init];
    [_positionBookmark loadFromDictionary:[dictionary objectForKey:NWPListKeyPosition]];
    
    return YES;
}

- (NSDictionary*)saveToDictionary
{
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:  (!_localPath)?@"":_localPath,   NWPListKeyLocalPath,
                                                                            [_bookCard saveToDictionary],   NWPListKeyBookCard,
                                                                            [_bookmarks saveToArray],       NWPListKeyBookmarks,
                                                                            [_positionBookmark dictionary],  NWPListKeyPosition,
                                                                            nil];
    
    [self saveCoverImage];
    return dictionary;
}

+ (NWBookCacheItem*)cacheItemWithBookCard:(NWBookCard*)bookCard localFileName:(NSString*)fileName
{
    NWBookCacheItem* item = [[NWBookCacheItem alloc] initWithBookCard:bookCard 
                                                        localFileName:fileName];
    return [item autorelease];
}

+ (NWBookCacheItem*)cacheItemFromDictionary:(NSDictionary*)dictionary
{
    NWBookCacheItem* item = [[[NWBookCacheItem alloc] init] autorelease];
    if ([item loadFromDictionary:dictionary])
    {
        return item;
    }
    return nil;
}

- (void)getCoverFileName
{
    if (!_localPath)
        return;
    
    NSString*   fileName = [[NSString stringWithFormat:@"%i", _bookCard.ID] stringByAppendingString:NAME_POSTFIX];
    NSString* filePath = [[[_localPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:COVER_FOLDER] stringByAppendingPathComponent:fileName];
    [_coverImagePath release];
    _coverImagePath = [[NSString alloc] initWithString:filePath];
}

- (void)saveCoverImage
{
    if (!_coverImagePath)
        [self getCoverFileName];
    
    if ((_coverImage) && (_coverImagePath)) {
        NSFileManager* fileMgr = [NSFileManager defaultManager];

        if ((![fileMgr fileExistsAtPath:_coverImagePath]) && (_coverImage)) {
            // create directory for covers cache (if dir not exists)
            NSFileManager* fileManager = [NSFileManager defaultManager];
            BOOL isDir = NO;
            NSString* dir = [_coverImagePath stringByDeletingLastPathComponent];

            if (![fileManager fileExistsAtPath:dir isDirectory:&isDir])
                [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];

            NSData* data = UIImagePNGRepresentation(_coverImage);
            BOOL result = [data writeToFile:_coverImagePath atomically:YES];
            result = result;
        }
    }
}

- (void)controlCoverFolderCountFiles
{
    if ([self coverFolderSize] >= COVER_TOTAL_COUNT_MAX) {
        if (!_coverImagePath)
            [self getCoverFileName];

        if (_coverImagePath) {
            NSFileManager* fileMgr = [NSFileManager defaultManager];
            NSString* coverFolder = [_coverImagePath stringByDeletingLastPathComponent];
            NSError* err = NULL;
            NSDirectoryEnumerator* files = [fileMgr enumeratorAtPath:coverFolder];
            NSString* file = [files nextObject];
        [fileMgr removeItemAtPath:file error:&err];
        }
    }
}

- (int)coverFolderSize
{
    if (!_coverImagePath)
        [self getCoverFileName];

    if (!_coverImagePath)
        return 0;

    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString* coverFolder = [_coverImagePath stringByDeletingLastPathComponent];
    int sz = (int)[fileMgr enumeratorAtPath:coverFolder].allObjects.count;

    return sz;
}

- (void)clearCoverImageFile
{
    if (!_coverImagePath)
        [self getCoverFileName];

    if (_coverImagePath) {
        NSFileManager* fileMgr = [NSFileManager defaultManager];

        if ([fileMgr fileExistsAtPath:_coverImagePath]) {
            NSError* err = NULL;
            [fileMgr removeItemAtPath:_coverImagePath error:&err];
        }
    }
}

- (void)loadCoverImage
{
    if (!_coverImagePath)
        [self getCoverFileName];
    if ((!_coverImage) && (_coverImagePath))
        _coverImage = [[UIImage alloc] initWithContentsOfFile:_coverImagePath];
}

@end
