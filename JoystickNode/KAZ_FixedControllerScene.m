//
//  KAZ_MyScene.m
//  VirtualControl
//
//  Created by Kevin Kazmierczak on 10/18/13.
//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import "KAZ_FixedControllerScene.h"
#import "KAZ_JoystickNode.h"

@interface KAZ_FixedControllerScene(){
    SKNode *control;
    SKSpriteNode *sprite;
    UITouch *joystickTouch;
    CGPoint touchPoint;
    CGSize move;
    
    KAZ_JoystickNode *moveJoystick;
    KAZ_JoystickNode *shootJoystick;
    CFTimeInterval lastUpdate;
}

@end

@implementation KAZ_FixedControllerScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        int xOffset = 150;
        int yOffset = 200;
        
        moveJoystick = [[KAZ_JoystickNode alloc] init];
        [moveJoystick setOuterControl:@"outer" withAlpha:0.25];
        [moveJoystick setInnerControl:@"inner" withAlpha:0.5 withName:@"MoveJoystick"];
        moveJoystick.speed = 8;
        moveJoystick.autoShowHide = NO;
        moveJoystick.position = CGPointMake(xOffset, yOffset);
        [self addChild:moveJoystick];
        
        shootJoystick = [[KAZ_JoystickNode alloc] init];
        [shootJoystick setOuterControl:@"outer" withAlpha:0.25];
        [shootJoystick setInnerControl:@"inner" withAlpha:0.5 withName:@"ShootJoystick"];
        shootJoystick.autoShowHide = NO;
        shootJoystick.position = CGPointMake(self.frame.size.width - xOffset, yOffset);
        shootJoystick.defaultAngle = 90;
        [self addChild:shootJoystick];
        
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        [sprite setScale:0.5];
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:sprite];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKNode *touchedNode = [self nodeAtPoint:location];
        if ( [touchedNode.name isEqualToString:@"MoveJoystick"] ){
            [moveJoystick startControlFromTouch:touch andLocation:location];
        } else if ( [touchedNode.name isEqualToString:@"ShootJoystick"] ){
            [shootJoystick startControlFromTouch:touch andLocation:location];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        if ( touch == moveJoystick.startTouch){
            [moveJoystick moveControlToLocation:touch andLocation:[touch locationInNode:self]];
        } else if ( touch == shootJoystick.startTouch){
            [shootJoystick moveControlToLocation:touch andLocation:[touch locationInNode:self]];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        if ( touch == moveJoystick.startTouch){
            [moveJoystick endControl];
        } else if ( touch == shootJoystick.startTouch){
            [shootJoystick endControl];
        }
    }
}

-(CGPoint)destPointForAngle:(float)angle{
    float angleInRadians = angle * M_PI / 180;
    // Just makes for an easy calculation
    float distanceToOffScreen = 1000;
    // Calculate Y Movement
    float moveY = distanceToOffScreen * sinf(angleInRadians);
    // Calculate X Movement
    float moveX = sqrtf(( distanceToOffScreen * distanceToOffScreen ) - ( moveY * moveY ) );
    BOOL isLeft = ABS(shootJoystick.angle) > 90;
    if ( isLeft ){
        moveX *= -1;
    }
    return CGPointMake(moveX, moveY);
}

-(void)update:(CFTimeInterval)currentTime {
    
    if ( currentTime - lastUpdate >= 0.5 ){
        [self shootBullet];
        lastUpdate = currentTime;
    }
    
    if ( moveJoystick.isMoving ){
        CGPoint adjustedSpritePosition = CGPointMake(sprite.position.x + moveJoystick.moveSize.width, sprite.position.y + moveJoystick.moveSize.height);
        if ( adjustedSpritePosition.x < 0 ){
            adjustedSpritePosition.x = 0;
        } else if ( adjustedSpritePosition.x > self.size.width ){
            adjustedSpritePosition.x = self.size.width;
        }
        if ( adjustedSpritePosition.y < 0 ){
            adjustedSpritePosition.y = 0;
        } else if ( adjustedSpritePosition.y > self.size.height ){
            adjustedSpritePosition.y = self.size.height;
        }
        sprite.position = adjustedSpritePosition;
    }
}

-(void)shootBullet{
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    bullet.position = sprite.position;
    [self addChild:bullet];
    
    CGPoint movePoint = [self destPointForAngle:shootJoystick.angle];
    CGPoint adjustedPoint = CGPointMake(sprite.position.x + movePoint.x, sprite.position.y + movePoint.y);
    
    SKAction *moveAction = [SKAction moveTo:adjustedPoint duration:1];
    SKAction *removeAction = [SKAction removeFromParent];
    [bullet runAction:[SKAction sequence:@[moveAction, removeAction]]];
}

@end
