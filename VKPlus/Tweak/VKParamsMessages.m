//
//  VKParamsMessages.m
//  VKParams
//
//  Created by Даниил on 14/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTweak.h"
#import "VKPlusAvatarProcessor.h"
#import "VKPlusAvatarButton.h"


CHDeclareClass(ChatController);
CHDeclareMethod(0, id, ChatController, typingService)
{
    if (hideMessageTyping)
        return nil;
    
    return CHSuper(0, ChatController, typingService);
}

CHDeclareMethod(0, void, ChatController, reportTyping)
{
    if (!hideMessageTyping)
        CHSuper(0, ChatController, reportTyping);
}

CHDeclareClass(MessagesModel);
CHDeclareMethod(1, void, MessagesModel, markMessageRead, id, message)
{
    if (!dontReadMessages)
        CHSuper(1, MessagesModel, markMessageRead, message);
}


CHDeclareClass(UnreadMessagesCounterHandler);
CHDeclareMethod(1, void, UnreadMessagesCounterHandler, unreadMessagesCounterUpdatedTo, long long, unreadMessagesCount)
{
    CHSuper(1, UnreadMessagesCounterHandler, unreadMessagesCounterUpdatedTo, unreadMessagesCount);
    
    cachedUnreadMessagesCount = unreadMessagesCount;
    updateMessagesBadge();
}


CHDeclareClass(SingleUserChatController);
BOOL chatIsEditing = NO;
CHDeclareMethod(0, void, SingleUserChatController, updateTitleView)
{
    CHSuper(0, SingleUserChatController, updateTitleView);
    
    if (!chatIsEditing && hideCallButton && ![currentUserID isEqual:self.did] && [self respondsToSelector:@selector(navigationItemComposer)]) {
        if (self.did.integerValue < 0)
            return;
        
        UIBarButtonItem *chatUserButton = objc_getAssociatedObject(self, "chatUserButton");
        if (chatUserButton) {
            self.navigationItem.rightBarButtonItem = chatUserButton;
            return;
        }
        
        CGRect buttonFrame = CGRectMake(0.0f, 0.0f, 36.0f, 36.0f);
        VKPlusAvatarButton *avatarButton = [VKPlusAvatarButton buttonWithFrame:buttonFrame userID:self.did];
        [avatarButton addTarget:self action:@selector(headerSelected) forControlEvents:UIControlEventTouchUpInside];
        
        chatUserButton = [[UIBarButtonItem alloc] initWithCustomView:avatarButton];
        self.navigationItem.rightBarButtonItem = chatUserButton;
        objc_setAssociatedObject(self, "chatUserButton", chatUserButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

CHDeclareMethod(2, void, SingleUserChatController, setEditing, BOOL, editing, animated, BOOL, animated)
{
    chatIsEditing = editing;
    CHSuper(2, SingleUserChatController, setEditing, editing, animated, animated);
}
