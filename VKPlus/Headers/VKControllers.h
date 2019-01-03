//
//  VKControllers.h
//  VKParams
//
//  Created by Даниил on 15/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

@class MainModel, MenuModel;

@interface VKMMainController : UITabBarController
@property (strong, nonatomic) id <UINavigationControllerDelegate> navigationControllerDelegate;
@property (strong, nonatomic) id <UINavigationControllerDelegate> navigationDelegate;
@property (readonly, retain, nonatomic) MainModel *main;
@property (strong, nonatomic) UIViewController *dialogsController;
@property (strong, nonatomic) UIViewController *menuController;

- (__kindof UINavigationController *)currentNavigationController;
@end


@interface MenuViewController : UIViewController
- (instancetype)initWithMain:(MainModel *)mainModel andModel:(MenuModel *)menuModel;
@end


@interface ChatController : UIViewController
@property(readonly, retain, nonatomic) NSNumber *did;
@end

@interface SingleUserChatController : ChatController
@end

@interface ModernSettingsController : UIViewController
@end
