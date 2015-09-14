//
//  KAZ_JoystickNode.m
//  VirtualControl
//
//  Created by Kevin Kazmierczak on 10/18/13.
//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import "KAZ_JoystickNode.h"

@interface KAZ_JoystickNode(){
    SKSpriteNode *outerControl;
    SKSpriteNode *innerControl;
    CGPoint startPoint;
}

@end

@implementation KAZ_JoystickNode

-(id)init{
    self = [super init];
    if ( self ){
        self.autoShowHide = YES;
    }
    return self;
}

-(void)setDefaultAngle:(float)defaultAngle{
    _defaultAngle = defaultAngle;
    self.angle = _defaultAngle;
}

-(void)setAutoShowHide:(BOOL)autoShowHide{
    _autoShowHide = autoShowHide;
    if ( _autoShowHide ){
        self.alpha = 0;
    } else {
        self.alpha = 1;
    }
}

-(void)setInnerControl:(NSString *)imageName withAlpha:(float)alpha withName:(NSString *)nodeName{
    [self setInnerControl:imageName withAlpha:alpha];
    innerControl.name = nodeName;
}

-(void)setInnerControl:(NSString *)imageName withAlpha:(float)alpha{
    if ( innerControl ){
        [innerControl removeFromParent];
    }
    
    innerControl = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    innerControl.alpha = alpha;
    [self addChild:innerControl];
}

-(void)setOuterControl:(NSString *)imageName withAlpha:(float)alpha{
    if ( outerControl ){
        [outerControl removeFromParent];
    }
    outerControl = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    outerControl.alpha = alpha;
    [self addChild:outerControl];
}

-(void)startControlFromTouch:(UITouch *)touch andLocation:(CGPoint)location{
    if ( self.autoShowHide ){
        self.alpha = 1;
        self.position = location;
    }
    self.startTouch = touch;
    startPoint = location;
    self.isMoving = YES;
}

-(void)moveControlToLocation:(UITouch *)touch andLocation:(CGPoint)location{
    // Get the outer ring radius
    float outerRadius = outerControl.size.width / 2;
    
    float movePoints = self.movePoints;
    // Get the change in X
    float deltaX = location.x - startPoint.x;
    // Get the change in Y
    float deltaY = location.y - startPoint.y;
    // Calculate the distance the stick is from the center point
    float distance = sqrtf((deltaX * deltaX) + (deltaY * deltaY));
    // Get the angle of movement
    self.angle = atan2f(deltaY, deltaX) * 180 / M_PI;
    // Is it moving left?
    BOOL isLeft = ABS(self.angle) > 90;
    // Convert the angle to radians
    float radians = self.angle * M_PI / 180;
    
    if ( distance < outerRadius ){
        // If the distance is less than the radius, it moves freely
        innerControl.position = [touch locationInNode:self];
        movePoints = distance / outerRadius * self.movePoints;
    } else {
        // If the distance is greater than the radius, we'll lock it to bounds of the outer size radius
        float maxY = outerRadius * sinf(radians);
        float maxX = sqrtf(( outerRadius * outerRadius ) - ( maxY * maxY ) );
        if ( isLeft ){
            maxX *= -1;
        }
        innerControl.position = CGPointMake(maxX, maxY);
        movePoints = self.movePoints;
    }
    
    // Calculate Y Movement
    float moveY = movePoints * sinf(radians);
    // Calculate X Movement
    float moveX = sqrtf(( movePoints * movePoints ) - ( moveY * moveY ) );
    // Adjust if it's going left
    if ( isLeft ){
        moveX *= -1;
    }
    
    self.moveSize = CGSizeMake(moveX, moveY);
}

-(void)endControl{
    self.isMoving = NO;
    [self reset];
}

-(void)reset{
    if ( self.autoShowHide ){
        self.alpha = 0;
    }
    self.moveSize = CGSizeMake(0, 0);
    self.angle = self.defaultAngle;
    innerControl.position = CGPointMake(0, 0);
}

@end
