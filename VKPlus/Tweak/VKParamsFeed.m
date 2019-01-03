//
//  VKParamsFeed.m
//  VKParams
//
//  Created by Даниил on 13/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTweak.h"


CHDeclareClass(VKPost);
CHDeclareMethod(2, BOOL, VKPost, process, NSDictionary *, item, context, id, context)
{
    if (disableAds && [item[@"marked_as_ads"] boolValue]) {
        return NO;
    }
    
    return CHSuper(2, VKPost, process, item, context, context);
}

CHDeclareClass(VKFeedAds);
CHDeclareMethod(2, BOOL, VKFeedAds, process, id, item, context, id, context)
{
    if (disableAds)
        return NO;
    
    return CHSuper(2, VKFeedAds, process, item, context, context);
}

CHDeclareClass(VKFeedActivityInlineComments);
CHDeclareMethod(2, BOOL, VKFeedActivityInlineComments, process, id, item, context, id, context)
{
    if (hideInlineComments)
        return NO;
    
    return CHSuper(2, VKFeedActivityInlineComments, process, item, context, context);
}

CHDeclareClass(VKFeedActivityLikes);
CHDeclareMethod(2, BOOL, VKFeedActivityLikes, process, id, item, context, id, context)
{
    if (hideFeedLikes)
        return NO;
    
    return CHSuper(2, VKFeedActivityLikes, process, item, context, context);
}

CHDeclareClass(VKFeedActivityComment);
CHDeclareMethod(2, BOOL, VKFeedActivityComment, process, id, item, context, id, context)
{
    if (hideFeedComments)
        return NO;
    
    return CHSuper(2, VKFeedActivityComment, process, item, context, context);
}

CHDeclareClass(VKAccountExperiments);
CHDeclareMethod(0, BOOL, VKAccountExperiments, new_posting)
{
    if (enableNewPosting)
        return YES;
    
    return CHSuper(0, VKAccountExperiments, new_posting);
}

CHDeclareClass(PollAnswerButton);
CHDeclareMethod(0, BOOL, PollAnswerButton, pollHasAnswer)
{
    if (forceShowPollResult)
        return YES;
    
    return CHSuper(0, PollAnswerButton, pollHasAnswer);
}

CHDeclareClass(VKStory)
CHDeclareMethod(2, BOOL, VKStory, process, NSDictionary *, item, context, id, context)
{
    if (disableAds && [item[@"is_ads"] boolValue])
        return NO;
    
    return CHSuper(2, VKStory, process, item, context, context);
}

CHDeclareClass(VKStoreProductSticker)
CHDeclareMethod(2, BOOL, VKStoreProductSticker, process, NSDictionary *, item, context, id, context)
{
    if (hidePromotedStickers && [item[@"promoted"] boolValue])
        return NO;
    
    return CHSuper(2, VKStoreProductSticker, process, item, context, context);
}
