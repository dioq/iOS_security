//
//  JailbreakTool.h
//  ReverseOC
//
//  Created by lzd_free on 2020/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JailbreakTool : NSObject

+(instancetype)sharedManager;
-(BOOL)isJailbroken;

@end

NS_ASSUME_NONNULL_END
