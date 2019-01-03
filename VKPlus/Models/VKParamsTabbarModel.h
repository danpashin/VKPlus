//
//  VKParamsTabbarModel.h
//  VKParams
//
//  Created by Даниил on 15/08/2018.
//  strongright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsTabbarModel : NSObject <NSSecureCoding>

+ (id)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTitle:(NSString *)title modelSelector:(NSString *)modelSelector;

@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *modelSelector;

@property (strong, nonatomic, nullable) NSString *imageName;
@property (strong, nonatomic, nullable) NSString *selectedImageName;
@property (assign, nonatomic) BOOL iconFromVKApp;

@end



@interface VKParamsTabbarModel (AutomaticCreation)

@property (strong, nonatomic, readonly, class) NSDictionary <NSNumber *, VKParamsTabbarModel *> *allModels;
@property (strong, nonatomic, readonly, class) NSDictionary <NSNumber *, VKParamsTabbarModel *> *defaultModels;

@end


#ifndef COMPILE_APP
@interface VKParamsTabbarModel (VKModule)

+ (BOOL)setupQuickMenuController;

+ (void)rebuildTabbarItems;

@end
#endif

NS_ASSUME_NONNULL_END
