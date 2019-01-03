//
//  VKParamsNews.m
//  VKParams
//
//  Created by Даниил on 13/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTweak.h"


CHDeclareClass(VKFeedRecommendedFriends);
CHDeclareMethod(2, BOOL, VKFeedRecommendedFriends, process, id, item, context, id, context)
{
    if (hideRecommendedFriends)
        return NO;
    
    return CHSuper(2, VKFeedRecommendedFriends, process, item, context, context);
}

CHDeclareClass(NewsSelectorController);
CHDeclareMethod(1, void, NewsSelectorController, panned, id, gestureRecognizer)
{
    if (!disableCameraSwipe)
        CHSuper(1, NewsSelectorController, panned, gestureRecognizer);
}


CHDeclareClass(StoriesModel);
CHDeclareMethod(1, void, StoriesModel, markStoryAsSeen, id, story)
{
    if (!dontReadStories)
        CHSuper(1, StoriesModel, markStoryAsSeen, story);
}

CHDeclareMethod(2, void, StoriesModel, markStoryAsSeen, id, story, fromSource, id, source)
{
    if (!dontReadStories)
        CHSuper(2, StoriesModel, markStoryAsSeen, story, fromSource, source);
}

CHDeclareMethod(2, void, StoriesModel, markStoryAsSeen, id, story, forAllStoriesFromSource, BOOL, source)
{
    if (!dontReadStories)
        CHSuper(2, StoriesModel, markStoryAsSeen, story, forAllStoriesFromSource, source);
}


CHDeclareClass(MainNewsFeedController);
CHDeclareMethod(0, id, MainNewsFeedController, storiesModel)
{
    if (hideStories)
        return nil;
    
    return CHSuper(0, MainNewsFeedController, storiesModel);
}

CHDeclareClass(MainModel);
CHDeclareMethod(0, id, MainModel, storiesModel)
{
    if (hideStories)
        return nil;
    
    return CHSuper(0, MainModel, storiesModel);
}

CHDeclareClass(VKPost);
CHDeclareMethod(1, void, VKPost, setAttachments, VKAttachments *, attachments)
{
    CHSuper(1, VKPost, setAttachments, attachments);
    
    if (!saveTraffic || ![attachments isKindOfClass:objc_lookUpClass("VKAttachments")])
        return;
    
    [attachments.attachments enumerateObjectsUsingBlock:^(id  _Nonnull attachment, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([attachment respondsToSelector:@selector(variants)]) {
            NSMutableDictionary *variants = [attachment sc_executeSelector:@selector(variants)];
            NSArray <NSNumber *> *sortedKeys = [variants.allKeys sortedArrayUsingSelector:@selector(compare:)];
            [sortedKeys enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSNumber * _Nonnull variantKey, NSUInteger variantIndex, BOOL * _Nonnull variantStop) {
                if (variantKey.integerValue > 1) {
                    [variants removeObjectForKey:variantKey];
                } else {
                    *variantStop = YES;
                }
            }];
        }
        
        if ([attachment isKindOfClass:objc_lookUpClass("VKVideo")]) {
            VKVideo *video = (VKVideo *)attachment;
            [video.firstFrameVariants removeAllObjects];
            video.no_autoplay = YES;
        }
        
        if ([attachment isKindOfClass:objc_lookUpClass("VKLink")]) {
            NSMutableDictionary *variants = ((VKLink *)attachment).photo.variants;
            [variants removeAllObjects];
        }
        
        if ([attachment isKindOfClass:objc_lookUpClass("VKDoc")]) {
            NSMutableDictionary *variants = ((VKDoc *)attachment).variants;
            [variants removeAllObjects];
        }
    }];
    
}

CHDeclareClass(PairController);
CHDeclareMethod(1, void, PairController, setScrollEnabled, BOOL, scrollEnabled)
{
    CHSuper(1, PairController, setScrollEnabled, disableCameraSwipe ? NO : scrollEnabled);
}

CHDeclareClass(DiscoverItem);
CHDeclareMethod(2, BOOL, DiscoverItem, process, NSDictionary *, item, context, id, context)
{
    if (hideStories && (item[@"stories"] || [item[@"template"] isEqualToString:@"lazy_stories"]))
        return NO;
    
    return CHSuper(2, DiscoverItem, process, item, context, context);
}
