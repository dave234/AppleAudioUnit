//
//  AAUParameterState.c
//  App
//
//  Created by David O'Neill on 12/15/18.
//

#include "AAUParameterState.h"

void AAUParameterStateSetValue(AAUParameterState *state, float value) {
    state->value = value;
    state->target = value;
    state->increment = 0;
    state->count = 0;
}

void AAUParameterStateSetRamp(AAUParameterState *state, float startValue, float targetValue, int durationInSamples) {
    if (durationInSamples < 1 || startValue == targetValue) {
        return AAUParameterStateSetValue(state, targetValue);
    }

    state->value = startValue;
    state->target = targetValue;
    state->increment = (state->target - state->value) / durationInSamples;
    state->count = durationInSamples;
}

float AAUParameterStateAdvance(AAUParameterState *state, int count) {
    if (state->count < 1) {
        return state->value;
    }

    count = count < state->count ? count : state->count;
    state->value += count * state->increment;
    state->count -= count;
    return state->value;
}

float AAUParameterStateAdvanceOne(AAUParameterState *state) {
    if (state->count < 1) {
        return state->value;
    }

    state->value += state->increment;
    state->count -= 1;
    return state->value;
}

float AAUParameterStateGetValue(AAUParameterState *state) {
    return state->value;
}

CWIFT_BOOL AAUParameterStateIsRamping(AAUParameterState *state) {
    return state->count > 0;
}

