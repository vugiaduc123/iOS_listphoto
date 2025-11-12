#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "Arrow" asset catalog image resource.
static NSString * const ACImageNameArrow AC_SWIFT_PRIVATE = @"Arrow";

/// The "bg_piscum" asset catalog image resource.
static NSString * const ACImageNameBgPiscum AC_SWIFT_PRIVATE = @"bg_piscum";

/// The "error" asset catalog image resource.
static NSString * const ACImageNameError AC_SWIFT_PRIVATE = @"error";

/// The "indicator" asset catalog image resource.
static NSString * const ACImageNameIndicator AC_SWIFT_PRIVATE = @"indicator";

/// The "loading" asset catalog image resource.
static NSString * const ACImageNameLoading AC_SWIFT_PRIVATE = @"loading";

#undef AC_SWIFT_PRIVATE
