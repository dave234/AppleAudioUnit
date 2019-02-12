//
//  AAUParameterState.h
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/15/18.
//

#ifndef ParameterState_h
#define ParameterState_h

#include <stdio.h>
#include <Cwift/Cwift.h>

typedef struct AAUParameterState {
    float value;
    float target;
    float increment;
    int count;
} AAUParameterState;


void        AAUParameterStateSetValue(AAUParameterState   *state, float value);
void        AAUParameterStateSetRamp(AAUParameterState    *state, float startValue, float targetValue, int durationInSamples);
float       AAUParameterStateAdvance(AAUParameterState    *state, int   count);
float       AAUParameterStateAdvanceOne(AAUParameterState *state);
float       AAUParameterStateGetValue(AAUParameterState   *state);
CWIFT_BOOL  AAUParameterStateIsRamping(AAUParameterState  *state);


#endif /* ParameterState_h */
