#import "cocos2d.h"

@interface TouchesSampleScene : CCScene {
@private
}
@end

@interface TouchesSampleLayer: CCLayer {
@private
  CCNode* upLeftGrid;
  CCNode* downLeftGrid;
  
  CCNode* topGrid;
  CCNode* bottomGrid;
  
  CCNode* upRightGrid;
  CCNode* downRightGrid;
  
  CCNode* lastNode;
}
@end

