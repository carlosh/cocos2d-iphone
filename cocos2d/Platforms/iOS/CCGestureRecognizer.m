//
//  CCGestureRecognizer.m
//  cocos
//
//  Created by Joe Allen on 7/11/10.
//  Copyright 2010 Glaiveware LLC. All rights reserved.
//

#import "CCGestureRecognizer.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CGPointExtension.h"

@implementation CCGestureRecognizer

-(void)dealloc
{
  CCLOGINFO( @"cocos2d: deallocing %@", self); 
  [m_gestureRecognizer release];
  [super dealloc];
}

- (UIGestureRecognizer*)gestureRecognizer
{
  return m_gestureRecognizer;
}

- (CCNode*)node
{
  return m_node;
}

- (void)setNode:(CCNode*)node
{
  m_node = node;
}

- (id<UIGestureRecognizerDelegate>)delegate
{
  return m_delegate;
}

- (void) setDelegate:(id<UIGestureRecognizerDelegate>)delegate
{
  m_delegate = delegate;
}

- (id)target
{
  return m_target;
}

- (void)setTarget:(id)target
{
  m_target = target;
}

- (SEL)callback
{
  return m_callback;
}

- (void)setCallback:(SEL)callback
{
  m_callback = callback;
}

- (id)initWithRecognizerTargetAction:(UIGestureRecognizer*)gestureRecognizer target:(id)target action:(SEL)action
{
  if( (self=[super init]) )
  {
    assert(gestureRecognizer != NULL && "gesture recognizer must not be null");
    m_gestureRecognizer = gestureRecognizer;
    [m_gestureRecognizer retain];
    [m_gestureRecognizer addTarget:self action:@selector(callback:)];
    
    // setup our new delegate
    m_delegate = m_gestureRecognizer.delegate;
    m_gestureRecognizer.delegate = self;
    
    m_target = target; // weak ref
    m_callback = action;
  }
  return self;
}

+ (id)CCRecognizerWithRecognizerTargetAction:(UIGestureRecognizer*)gestureRecognizer target:(id)target action:(SEL)action
{
  return [[[self alloc] initWithRecognizerTargetAction:gestureRecognizer target:target action:action] autorelease];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  assert( m_node != NULL && "gesture recognizer must have a node" );
    
  CGPoint pt = [[CCDirector sharedDirector] convertToGL:[touch locationInView: [touch view]]];
  /* do a rotation opposite of the node to see if the point is in it
     it should make it easier to check against an aligned object */
  
  BOOL rslt = [m_node isPointInArea:pt];
  if( rslt )
  {
    /*  ok we know this node was touched, but now we need to make sure
        no other node above this one was touched -- this check only includes
        nodes that receive touches */
    
    CCNode* node;
    // now check children of parents after this node
    node = m_node;
    CCNode* parent = m_node.parent;
    while( node != nil && rslt)
    {
      CCNode* child;
      BOOL nodeFound = NO;
      CCARRAY_FOREACH(parent.children, child)
      {
        if( !nodeFound )
        {
          if( !nodeFound && node == child )
            nodeFound = YES;  // we need to keep track of until we hit our node, any past it have a higher z value
          continue;
        }
        
        if( [child isNodeInTreeTouched:pt] )
        {
          rslt = NO;
          break;
        }
      }
      
      node = parent;
      parent = node.parent;
    }    
  }
  
  if( rslt && m_delegate )
    rslt = [m_delegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
  
  return rslt;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  if( !m_delegate )
    return YES;
  return [m_delegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if( !m_delegate || ![m_delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)] )
    return YES;
  return [m_delegate gestureRecognizerShouldBegin:gestureRecognizer];
}

- (void)callback:(UIGestureRecognizer*)recognizer
{
  if( m_target )
    [m_target performSelector:m_callback withObject:recognizer withObject:m_node];
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
  [coder encodeObject:m_gestureRecognizer forKey:@"gestureRecognizer"];
  [coder encodeObject:m_node forKey:@"node"];
  [coder encodeObject:m_delegate forKey:@"delegate"];
  
  [coder encodeObject:m_target forKey:@"target"];
  [coder encodeObject:NSStringFromSelector(m_callback) forKey:@"callback"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
  self=[self init];
  if (self) 
  {
    // don't retain node, it will retain this
    m_node = [decoder decodeObjectForKey:@"node"];          // weak ref
    m_delegate = [decoder decodeObjectForKey:@"delegate"];  // weak ref
    m_target = [decoder decodeObjectForKey:@"target"];      // weak ref
    m_callback = NSSelectorFromString([decoder decodeObjectForKey:@"callback"]);
   
    m_gestureRecognizer = [[decoder decodeObjectForKey:@"gestureRecognizer"] retain];
    [m_gestureRecognizer addTarget:self action:@selector(callback:)];
    m_gestureRecognizer.delegate = self;
  }
  return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | %@ | Node = %@ >", [self class], self, [m_gestureRecognizer class], m_node];
}

@end
#pragma mark NSCoding of built in recognizers

@implementation UIRotationGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{}

- (id)initWithCoder:(NSCoder *)decoder 
{
  self=[self init];
  if (self) 
  {}
  return self;
}
@end

@implementation UITapGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
  [coder encodeInt:self.numberOfTapsRequired forKey:@"numberOfTapsRequired"];
  [coder encodeInt:self.numberOfTouchesRequired forKey:@"numberOfTouchesRequired"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
  self=[self init];
  if (self) 
  {
    int taps = [decoder decodeIntForKey:@"numberOfTapsRequired"];
    if( self.numberOfTapsRequired != taps)
      self.numberOfTapsRequired = taps;

    int touches = [decoder decodeIntForKey:@"numberOfTouchesRequired"];
    if( self.numberOfTouchesRequired != touches )
      self.numberOfTouchesRequired = touches;
  }
  return self;
}
@end

@implementation UIPanGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
  [coder encodeInt:self.minimumNumberOfTouches forKey:@"minimumNumberOfTouches"];
  [coder encodeInt:self.maximumNumberOfTouches forKey:@"maximumNumberOfTouches"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
  self=[self init];
  if (self) 
  {
    int minTouches = [decoder decodeIntForKey:@"minimumNumberOfTouches"];
    if( self.minimumNumberOfTouches != minTouches )
      self.minimumNumberOfTouches = minTouches;
    
    int maxTouches = [decoder decodeIntForKey:@"maximumNumberOfTouches"];
    if( self.maximumNumberOfTouches != maxTouches )
      self.maximumNumberOfTouches = maxTouches;
  }
  return self;
}
@end

@implementation UILongPressGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
  [coder encodeInt:self.numberOfTapsRequired forKey:@"numberOfTapsRequired"];
  [coder encodeInt:self.numberOfTouchesRequired forKey:@"numberOfTouchesRequired"];
  [coder encodeDouble:self.minimumPressDuration forKey:@"minimumPressDuration"];
  [coder encodeFloat:self.allowableMovement forKey:@"allowableMovement"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
  self=[self init];
  if (self) 
  {
    int taps = [decoder decodeIntForKey:@"numberOfTapsRequired"];
    if( self.numberOfTapsRequired != taps )
      self.numberOfTapsRequired = taps;
    
    int touches = [decoder decodeIntForKey:@"numberOfTouchesRequired"];
    if( self.numberOfTouchesRequired != touches )
      self.numberOfTouchesRequired = touches;
    
    double duration = [decoder decodeDoubleForKey:@"minimumPressDuration"];
    if( self.minimumPressDuration != duration )
      self.minimumPressDuration = duration;
    
    float movement = [decoder decodeFloatForKey:@"allowableMovement"];
    if( self.allowableMovement != movement )
      self.allowableMovement = movement;
  }
  return self;
}
@end

@implementation UISwipeGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
  [coder encodeInt:self.numberOfTouchesRequired forKey:@"numberOfTouchesRequired"];
  [coder encodeInt:self.direction forKey:@"direction"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
  self=[self init];
  if (self) 
  {
    int touches = [decoder decodeIntForKey:@"numberOfTouchesRequired"];
    if( self.numberOfTouchesRequired != touches )
      self.numberOfTouchesRequired = touches;
    
    UISwipeGestureRecognizerDirection direction = (UISwipeGestureRecognizerDirection)[decoder decodeIntForKey:@"direction"];
    if( self.direction != direction )
      self.direction = direction;
  }
  return self;
}
@end

@implementation UIPinchGestureRecognizer(NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder 
{
}

- (id)initWithCoder:(NSCoder *)decoder 
{
  self=[self init];
  if (self) 
  {
  }
  return self;
}
@end
