/**
 * Circom Circuit Definition for Age Verification
 * 
 * This circuit proves that: currentAge >= minimumAge
 * without revealing the actual birth date.
 * 
 * Inputs:
 *  - birthDateTimestamp (private): Birth date as Unix timestamp
 *  - currentTimestamp (public): Current date as Unix timestamp
 *  - minimumAge (public): Minimum age requirement in years
 * 
 * Output:
 *  - isValid: 1 if age >= minimumAge, 0 otherwise
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 * Author: Zeng Han Jun
 */

pragma circom 2.0.0;

include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/gates.circom";

// Helper: Convert years to seconds (approximate)
// 1 year ≈ 365.25 days * 24 hours * 60 minutes * 60 seconds
template YearsToSeconds() {
    signal input years;
    signal output seconds;
    
    // 365.25 * 24 * 60 * 60 = 31557600 seconds per year
    seconds <== years * 31557600;
}

// Main age verification circuit
template AgeVerification() {
    // Private input - not revealed in proof
    signal input birthDateTimestamp;
    
    // Public inputs - visible to verifier
    signal input currentTimestamp;
    signal input minimumAge;
    
    // Output
    signal output isValid;
    
    // Calculate age in seconds
    signal ageInSeconds;
    ageInSeconds <== currentTimestamp - birthDateTimestamp;
    
    // Convert minimum age to seconds
    component yearsToSec = YearsToSeconds();
    yearsToSec.years <== minimumAge;
    
    signal minimumAgeInSeconds;
    minimumAgeInSeconds <== yearsToSec.seconds;
    
    // Check if actual age >= minimum age
    component greaterEq = GreaterEqThan(64); // 64-bit comparison
    greaterEq.in[0] <== ageInSeconds;
    greaterEq.in[1] <== minimumAgeInSeconds;
    
    isValid <== greaterEq.out;
    
    // Constraint: isValid must be 0 or 1
    isValid * (1 - isValid) === 0;
    
    // Additional constraints for validity:
    // 1. Birth date must be in the past
    component birthInPast = LessThan(64);
    birthInPast.in[0] <== birthDateTimestamp;
    birthInPast.in[1] <== currentTimestamp;
    birthInPast.out === 1;
    
    // 2. Minimum age must be reasonable (0-150 years)
    component ageReasonable = LessThan(32);
    ageReasonable.in[0] <== minimumAge;
    ageReasonable.in[1] <== 151;
    ageReasonable.out === 1;
}

// Main component
component main {public [currentTimestamp, minimumAge]} = AgeVerification();
