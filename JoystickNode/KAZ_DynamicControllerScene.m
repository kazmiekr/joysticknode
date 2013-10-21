//
//  KAZ_MyScene.m
//  VirtualControl
//
//  Created by Kevin Kazmierczak on 10/18/13.
//  Copyright (c) 2013 Kevin Kazmierczak. All rights reserved.
//

#import "KAZ_DynamicControllerScene.h"
#import "KAZ_JoystickNode.h"

@interface KAZ_DynamicControllerScene(){
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

@implementation KAZ_DynamicControllerScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

        [self createMoveHelper];
        [self createShootHelper];
        
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        [sprite setScale:0.5];
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:sprite];
        
        moveJoystick = [[KAZ_JoystickNode alloc] init];
        [moveJoystick setOuterControl:@"outer" withAlpha:0.25];
        [moveJoystick setInnerControl:@"inner" withAlpha:0.5];
        moveJoystick.speed = 8;
        [self addChild:moveJoystick];
        
        shootJoystick = [[KAZ_JoystickNode alloc] init];
        [shootJoystick setOuterControl:@"outer" withAlpha:0.25];
        [shootJoystick setInnerControl:@"inner" withAlpha:0.5];
        shootJoystick.defaultAngle = 90; // Default angle to report straight up for firing towards top
        [self addChild:shootJoystick];
    }
    return self;
}

-(void)createShootHelper{
    
    SKShapeNode *shape = [SKShapeNode node];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(self.size.width / 2, 0, self.size.width / 2, self.size.height));
    shape.path = path;
    shape.fillColor = [UIColor greenColor];
    shape.strokeColor = [UIColor whiteColor];
    shape.position = CGPointMake(0, 0);
    shape.alpha = 0.25;
    [self addChild:shape];
    CGPathRelease(path);
    
    SKLabelNode *helper = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    helper.fontColor = [UIColor whiteColor];
    helper.fontSize = 14;
    helper.text = @"Tap here to show fire joystick";
    helper.position = CGPointMake(self.size.width / 2 + self.size.width / 4, CGRectGetMidY(shape.frame));
    [self addChild:helper];
}

-(void)createMoveHelper{
    
    SKShapeNode *shape = [SKShapeNode node];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, self.size.width / 2, self.size.height));
    shape.path = path;
    shape.fillColor = [UIColor grayColor];
    shape.strokeColor = [UIColor whiteColor];
    shape.position = CGPointMake(0, 0);
    shape.alpha = 0.25;
    [self addChild:shape];
    CGPathRelease(path);
    
    SKLabelNode *helper = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    helper.fontColor = [UIColor whiteColor];
    helper.fontSize = 14;
    helper.text = @"Tap here to show move joystick";
    helper.position = CGPointMake(self.size.width / 2 / 2, CGRectGetMidY(shape.frame));
    [self addChild:helper];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        // If the user touches the left side of the screen, use the move joystick
        if ( location.x < self.size.width / 2 ){
            [moveJoystick startControlFromTouch:touch andLocation:location];
        } else {
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
    
    // Shoot bullets every half second
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

-(void)adjustForBounds:(CGPoint)point{
    if ( point.x < 0 ){
        point.x = 0;
    } else if ( point.x > self.size.width ){
        point.x = self.size.width;
    }
    if ( point.y < 0 ){
        point.y = 0;
    } else if ( point.y > self.size.height ){
        point.y = self.size.height;
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
