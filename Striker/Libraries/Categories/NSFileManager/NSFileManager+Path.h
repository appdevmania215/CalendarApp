
#import <Foundation/Foundation.h>

@interface NSFileManager (Path)
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectoryURL;

@end
