//
//  VKParamsTabbarModel+AutomaticCreation.m
//  VKParams
//
//  Created by Даниил on 18/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTabbarModel.h"

#import <objc/runtime.h>
#import <objc/message.h>


extern NSString *applicationBuildNumber;


@implementation VKParamsTabbarModel (AutomaticCreation)

+ (NSDictionary <NSNumber *, VKParamsTabbarModel *> *)allModels
{
    NSMutableDictionary <NSNumber *, VKParamsTabbarModel *> *mutableModels = [NSMutableDictionary dictionary];
    
    Class class = [VKParamsTabbarModel class];
    Class metaclass = objc_getMetaClass(class_getName(class));
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(metaclass, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        SEL methodSel = method_getName(method);
        if (method_getNumberOfArguments(method) == 2 && strstr(sel_getName(methodSel), "Model") != NULL 
            && methodSel != @selector(allModels) && methodSel != @selector(defaultModels)) {
            
            id (*getModel)(id self, SEL _cmd) = (void *)method_getImplementation(method);
            
            id object = getModel(nil, methodSel);
            if ([object isKindOfClass:class]) {
                mutableModels[@(mutableModels.count)] = object;
            }
        }
    }
    
    free(methods);
    
    NSMutableArray *sortedModels = mutableModels.allValues.mutableCopy;
    [sortedModels sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
    
    NSArray *sortedKeys = [mutableModels.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    return [[NSDictionary alloc] initWithObjects:sortedModels forKeys:sortedKeys];
}

+ (NSDictionary <NSNumber *, VKParamsTabbarModel *> *)defaultModels
{
    return @{@0:self.newsFeedModel, @1:self.discoverModel, @2:self.dialogsModel, @3:self.feedbackModel, @4:self.menuModel};
}

+ (VKParamsTabbarModel *)newsFeedModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"News") modelSelector:@"selectorNews"];
    model.imageName = @"tabbar/newsfeed";
    model.selectedImageName = @"tabbar/newsfeed_active";
    model.iconFromVKApp = YES;
    return model;
}

+ (VKParamsTabbarModel *)discoverModel
{
    VKParamsTabbarModel *model = nil;
    
    if (applicationBuildNumber.integerValue >= 549)
        model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Recommendations") modelSelector:@"discoverWithSearch"];
    else
        model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Recommendations") modelSelector:@"discover"];
    
    model.imageName = @"tabbar/search";
    model.selectedImageName = @"tabbar/search_active";
    model.iconFromVKApp = YES;
    return model;
}

+ (VKParamsTabbarModel *)dialogsModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Messages") modelSelector:@"messagesDialogs"];
    model.imageName = @"tabbar/messages";
    model.selectedImageName = @"tabbar/messages_active";
    model.iconFromVKApp = YES;
    return model;
}

+ (VKParamsTabbarModel *)feedbackModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Notifications") modelSelector:@"selectorFeedback"];
    model.imageName = @"tabbar/notifications";
    model.selectedImageName = @"tabbar/notifications_active";
    model.iconFromVKApp = YES;
    return model;
}

+ (VKParamsTabbarModel *)menuModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"More") modelSelector:@"menu"];
    model.imageName = @"tabbar/more";
    model.selectedImageName = @"tabbar/more_active";
    model.iconFromVKApp = YES;
    return model;
}

+ (VKParamsTabbarModel *)liveVideoModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Live Streams") modelSelector:@"liveVideoFiltersSelector"];
    model.imageName = @"tabbar/live_normal_24";
    model.selectedImageName = @"tabbar/live_active_24";
    return model;
}

+ (VKParamsTabbarModel *)gamesModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Games") modelSelector:@"appsDashboard"];
    model.imageName = @"tabbar/games_normal_24";
    model.selectedImageName = @"tabbar/games_active_24";
    return model;
}

+ (VKParamsTabbarModel *)videosModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Videos") modelSelector:@"primaryVideo"];
    model.imageName = @"tabbar/video_normal_24";
    model.selectedImageName = @"tabbar/video_active_24";
    return model;
}

+ (VKParamsTabbarModel *)settingsModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Settings") modelSelector:@"settings"];
    model.imageName = @"tabbar/settings_normal_24";
    model.selectedImageName = @"tabbar/settings_active_24";
    return model;
}

+ (VKParamsTabbarModel *)favesModel
{
    VKParamsTabbarModel *model = nil;
    
    if (applicationBuildNumber.integerValue >= 163)
        model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Bookmarks") modelSelector:@"favoritesWithInitialSection:"];
    else
        model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Bookmarks") modelSelector:@"selectorFaves"];
    
    model.imageName = @"tabbar/bookmarks_normal_24";
    model.selectedImageName = @"tabbar/bookmarks_active_24";
    return model;
}

+ (VKParamsTabbarModel *)audiosModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Music") modelSelector:@"selectorAudio"];
    model.imageName = @"tabbar/music_normal_24";
    model.selectedImageName = @"tabbar/music_active_24";
    return model;
}

+ (VKParamsTabbarModel *)groupsModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Communities") modelSelector:@"selectorGroups"];
    model.imageName = @"tabbar/community_normal_24";
    model.selectedImageName = @"tabbar/community_active_24";
    return model;
}

+ (VKParamsTabbarModel *)friendsModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Friends") modelSelector:@"selectorFriends"];
    model.imageName = @"tabbar/friends_normal_24";
    model.selectedImageName = @"tabbar/friends_active_24";
    return model;
}

+ (VKParamsTabbarModel *)documentsModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Documents") modelSelector:@"docs:"];
    model.imageName = @"tabbar/documents_normal_24";
    model.selectedImageName = @"tabbar/documents_active_24";
    return model;
}

+ (VKParamsTabbarModel *)photosModel
{
    VKParamsTabbarModel *model = [[VKParamsTabbarModel alloc] initWithTitle:VKPLocalized(@"Photos") modelSelector:@"photos:userOnly:"];
    model.imageName = @"tabbar/photos_normal_24";
    model.selectedImageName = @"tabbar/photos_active_24";
    return model;
}

@end
