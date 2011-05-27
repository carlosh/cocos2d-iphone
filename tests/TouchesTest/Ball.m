/* TouchesTest (c) Valentin Milea 2009
 */
#import "Ball.h"
#import "Paddle.h"

@implementation Ball

@synthesize velocity;

- (float)radius
{
	return self.texture.contentSize.width / 2;
}

+ (id)ballWithTexture:(CCTexture2D *)aTexture
{
	return [[[self alloc] initWithTexture:aTexture] autorelease];
}

-(id)initWithTexture:(CCTexture2D *)aTexture
{
  self = [super initWithTexture:aTexture];
  if( self )
  {
    isTouchEnabled_ = YES;
    CCGestureRecognizer* pan = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[[UIPanGestureRecognizer alloc]init]autorelease] target:self action:@selector(throw:node:)];
    [self addGestureRecognizer:pan];
  }
  return self;
}

-(void)throw:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*)recognizer;
  static CGPoint last;
  static CGPoint delta;
  
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];

  switch ([pan state] ) 
  {
    case UIGestureRecognizerStateBegan:
    {
      last = pt;
      break;
    }
    case UIGestureRecognizerStateChanged:
    {
      delta = ccpSub(pt,last);
      self.position = ccpAdd(self.position, delta );
      last = pt;
      break;
    }
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
    {
      velocity = ccpMult(delta,60.0f);
      break;
    }
    default:
      break;
  }      
}

- (void)move:(ccTime)delta
{
	self.position = ccpAdd(self.position, ccpMult(velocity, delta));
	
	if (self.position.x > 320 - self.radius) {
		[self setPosition: ccp( 320 - self.radius, self.position.y)];
		velocity.x *= -1;
	} else if (self.position.x < self.radius) {
		[self setPosition: ccp(self.radius, self.position.y)];
		velocity.x *= -1;
	}
}

- (void)collideWithPaddle:(Paddle *)paddle
{
	CGRect paddleRect = paddle.rect;
	paddleRect.origin.x += paddle.position.x;
	paddleRect.origin.y += paddle.position.y;
	
	float lowY = CGRectGetMinY(paddleRect);
	float midY = CGRectGetMidY(paddleRect);
	float highY = CGRectGetMaxY(paddleRect);
	
	float leftX = CGRectGetMinX(paddleRect);
	float rightX = CGRectGetMaxX(paddleRect);
	
	if (self.position.x > leftX && self.position.x < rightX) {
	
		BOOL hit = NO;
		float angleOffset = 0.0f; 
		
		if (self.position.y > midY && self.position.y <= highY + self.radius) {
			self.position = CGPointMake(self.position.x, highY + self.radius);
			hit = YES;
			angleOffset = (float)M_PI / 2;
		}

		else if (self.position.y < midY && self.position.y >= lowY - self.radius) {
			self.position = CGPointMake(self.position.x, lowY - self.radius);
			hit = YES;
			angleOffset = -(float)M_PI / 2;
		}
		
		if (hit) {
			float hitAngle = ccpToAngle(ccpSub(paddle.position, self.position)) + angleOffset;
			
			float scalarVelocity = ccpLength(velocity) * 1.05f;
			float velocityAngle = -ccpToAngle(velocity) + 0.5f * hitAngle;
			
			velocity = ccpMult(ccpForAngle(velocityAngle), scalarVelocity);
		}
	}	
}

@end
