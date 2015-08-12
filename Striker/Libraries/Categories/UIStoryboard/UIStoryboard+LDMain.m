#import "UIStoryboard+LDMain.h"

UIStoryboard *_mainStoryboard = nil;

@implementation UIStoryboard (LDMain)

+ (instancetype)LDMainStoryboard {
    if (!_mainStoryboard) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *storyboardName = [bundle objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
        _mainStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
    }
    return _mainStoryboard;
}

@end