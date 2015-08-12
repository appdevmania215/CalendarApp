
#import "NSString+Capitalized.h"

@implementation NSString (Capitalized)

- (NSString*)stringWithCapitalizedFirstCharacter{
    if ([self length] > 0){
        
        return [self stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                             withString:[[self substringToIndex:1] capitalizedString]];
    }
    else{
        return @"";
    }
}
@end
