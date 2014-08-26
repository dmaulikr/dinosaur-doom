//
//  Gameplay.m
//  Dinosaurz
//
//  Created by George Pearman on 4/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "dinosaur.h"
#import "NeckMoveDino.h"
#define XTOLERANCE 10
#define YTOLERANCE 5
#define SPEED 1.5

@implementation Gameplay
{
    CCNode *_gameplayNode;
    NSMutableArray *dinos;
    float moveNeckAmt;
    NeckMoveDino* _neckMoveDino;
    CCLabelTTF* _scoreLabel;
    CCLabelTTF* _loseLabel;
    int score;
    CCButton* _tryAgain;
}

- (id)init
{
    if (self = [super init])
    {
        moveNeckAmt = -.03 * SPEED;
        [self schedule:@selector(moveNeck) interval:.05 / SPEED];
        [self schedule:@selector(moveDinos) interval:.015 / SPEED];
        [self schedule:@selector(addDino) interval:4 / SPEED];
        
        
    }
	return self;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    dinos = [[NSMutableArray alloc] init];
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    _neckMoveDino = (NeckMoveDino*) [CCBReader load:@"Dino"];
    CGPoint dinoPos = ccp(100, 70);
    _neckMoveDino.position = [_gameplayNode convertToNodeSpace:dinoPos];
    [_gameplayNode addChild:_neckMoveDino];
    [_scoreLabel setString:@"0"];
    [_loseLabel setString:@""];
    score = 0;
    [_tryAgain setVisible:false];
    [_tryAgain setUserInteractionEnabled:false];
    
}

- (void)moveDinos {
    for( int i = 0; i < [dinos count]; i++ )
    {
        NeckMoveDino* dino = [dinos objectAtIndex:i];
        dino.position = ccpSub(dino.position, ccp(.5, 0));
        
        if( dino.position.x < 0 )
        {
            [dinos removeObjectAtIndex:i--];
            [_gameplayNode removeChild:dino];
            [_loseLabel setString:@"You failed to defeat all the dinosaurs!"];
            [self unschedule:@selector(moveNeck)];
            [self unschedule:@selector(moveDinos)];
            [self unschedule:@selector(addDino)];
            [_tryAgain setVisible:true];
            [_tryAgain setUserInteractionEnabled:true];
        }
        
        else if( abs( [_gameplayNode convertToWorldSpace:dino.position].x - [_gameplayNode convertToWorldSpace: _neckMoveDino.position].x ) < XTOLERANCE && abs( [_gameplayNode convertToNodeSpace:dino->_head.position].y - [_gameplayNode convertToNodeSpace:_neckMoveDino->_head.position].y ) < YTOLERANCE )
        {

            [dinos removeObjectAtIndex:i--];
            [_gameplayNode removeChild:dino];
            
            CCParticleSystem * particles = [CCBReader load:@"Particles"];
            particles.position = ccp( 110, 80 + _neckMoveDino->_head.position.y );
            [_gameplayNode addChild:particles];
            
            [_scoreLabel setString:[NSString stringWithFormat:@"%i", ++score]];
        }
    }
}

- (void) addDino {
    NeckMoveDino* dino = [CCBReader load:@"Dino"];
    dino.scaleX = -1;
    float randomNeck = (float)rand() / RAND_MAX;
    if ( rand() % 2 == 0 )
    {
        randomNeck = randomNeck * 2;
    }
    dino->_neck.scaleY = randomNeck;
    dino->_head.position = ccp( dino->_head.position.x, dino->_head.position.y + ( randomNeck - 1 ) * 40 );
    
    CGPoint dinoPos = ccp(650, 70);
    dino.position = [_gameplayNode convertToNodeSpace:dinoPos];
    [_gameplayNode addChild:dino];
    [dinos addObject:dino];
}

- (void) moveNeck {
    if( _neckMoveDino->_neck.scaleY + moveNeckAmt < 2 && _neckMoveDino->_neck.scaleY + moveNeckAmt > 0 )
    {
        _neckMoveDino->_neck.scaleY = _neckMoveDino->_neck.scaleY + moveNeckAmt;
        _neckMoveDino->_head.position = ccpAdd(_neckMoveDino->_head.position, ccp(0,moveNeckAmt * 40) );
    }
    
}
                            
- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    moveNeckAmt = moveNeckAmt * -1;
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    moveNeckAmt = moveNeckAmt * -1;
}

-(void) tryAgain
{
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

@end
