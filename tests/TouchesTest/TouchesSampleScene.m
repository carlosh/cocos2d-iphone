//
//  TouchesSampleScene.m
//  cocos2d-ios
//
//  Created by Joe Allen on 6/26/11.
//  Copyright 2011 Glaive Games. All rights reserved.
//

#import "TouchesSampleScene.h"
@implementation TouchesSampleScene
-(id) init
{
  if( (self=[super init]) )
  {
    [self addChild:[TouchesSampleLayer node]];
  }
  return self;
}

@end

@interface TouchesSampleLayer (Private)
-(CCNode*)setupGrid;
-(void)setupUnit;
-(void)setupBackground;
-(void)setupTouch:(CCNode*)node callback:(SEL)callback;
-(void)select:(UIGestureRecognizer *)recognizer node:(CCNode *)node;
-(void)move:(UIGestureRecognizer *)recognizer node:(CCNode *)node;
-(void)enable:(CCNode*)node val:(BOOL)val;
@end

@implementation TouchesSampleLayer

-(id) init
{
  if( (self=[super init]) )
  {
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
      scale = 2.0f;
      width = 768.0f;
      height = 1024.0f;
    }
    else 
    {
      scale = 1.0f;
      width = 320.0f;
      height = 480.0f;
    }
    [self setupBackground];
    [self setupUnit];
  }
  return self;
}

-(void) move:(UIGestureRecognizer *)recognizer node:(CCNode *)node
{
  [lastNode runAction:[CCMoveTo actionWithDuration:1.0f position:node.position]];
  [self enable:upLeftGrid val:NO];
  [self enable:downLeftGrid val:NO];
  [self enable:upRightGrid val:NO];
  [self enable:downRightGrid val:NO];
  [self enable:topGrid val:NO];
  [self enable:bottomGrid val:NO];
}

-(void) select:(UIGestureRecognizer *)recognizer node:(CCNode *)node
{
  lastNode = node;
  
  CGPoint pos = node.position;
  // setup our move nodes
  upLeftGrid.position = ccpAdd(ccp(-37.5f*scale,23.0f*scale), pos);
  [self enable:upLeftGrid val:YES];
  downLeftGrid.position = ccpAdd(ccp(-37.5f*scale,-23.0f*scale), pos);
  [self enable:downLeftGrid val:YES];
  
  upRightGrid.position = ccpAdd(ccp(37.5f*scale,23.0f*scale), pos);
  [self enable:upRightGrid val:YES];
  downRightGrid.position = ccpAdd(ccp(37.5f*scale,-23.0f*scale), pos);
  [self enable:downRightGrid val:YES];
  
  topGrid.position = ccpAdd(ccp(0.0f*scale,46.0f*scale), pos);
  [self enable:topGrid val:YES];
  
  bottomGrid.position = ccpAdd(ccp(0.0f*scale,-46.0f*scale), pos);
  [self enable:bottomGrid val:YES];
}

-(void) enable:(CCNode*)node val:(BOOL)val
{
  node.isTouchEnabled = val;
  node.visible = val;
}

-(void) setupUnit
{
  NSString* unit = @"unit.png";
  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    unit = @"unit-hd.png";
  
  CCSprite* sprite = [CCSprite spriteWithFile:unit];
  sprite.position = ccp(150*scale,230*scale);
  [self addChild:sprite];
  [self setupTouch:sprite callback:@selector(select:node:)];
  
  sprite = [CCSprite spriteWithFile:unit];
  sprite.position = ccp(75*scale,230*scale);
  [self addChild:sprite];
  [self setupTouch:sprite callback:@selector(select:node:)];
  
  sprite = [CCSprite spriteWithFile:unit];
  sprite.position = ccp(225*scale,230*scale);
  [self addChild:sprite];
  [self setupTouch:sprite callback:@selector(select:node:)];
  
  upLeftGrid = [self setupGrid];
  downLeftGrid = [self setupGrid];
  upRightGrid = [self setupGrid];
  downRightGrid = [self setupGrid];
  topGrid = [self setupGrid];
  bottomGrid = [self setupGrid];
}

-(CCNode*)setupGrid
{
  NSString* grid = @"grid.png";
  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    grid = @"grid-hd.png";
  CCSprite* sprite = [CCSprite spriteWithFile:grid];
  sprite.visible = NO;
  [self addChild:sprite];
  [self setupTouch:sprite callback:@selector(move:node:)];
  return sprite;
}

-(void) setupTouch:(CCNode*)node callback:(SEL)callback
{
  node.isTouchEnabled = YES;
  [node addGestureRecognizer:[CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[[UITapGestureRecognizer alloc]init]autorelease] target:self action:callback]];
}

-(void)setupBackground
{
  float x = 0;
  float y = 0;
  int row = 0;
  NSString* grass = @"grass.png";
  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    grass=@"grass-hd.png";
  
  while( y < (height+(21.5*scale)) )
  {
    while( x < width )
    {
      CCSprite* sprite = [CCSprite spriteWithFile:grass];
      sprite.position = ccp(x,y);
      [self addChild:sprite];
      x += 75*scale;
    }
    row += 1;
    if( (row%2) == 0 )
      x = 0.0f;
    else
      x = 37.5f*scale;

    y += 23.0f*scale;
  }
}

@end


