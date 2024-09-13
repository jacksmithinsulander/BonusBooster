// SPDX-License-Identifier: ISC
pragma solidity 0.8.27;

/**
 * @title Bonus Errors
 * @notice Library to manage errors in the Bonus contract
 * @author https://x.com/0xjsieth
 *
 */
library BonusErrors{
    // Error thrown if user does not own any op tokens
    error YOU_DO_NOT_OWN_ANY_OP();

    // Error thrown if user does not own any boosters
    error YOU_DONT_OWN_ANY_BOOSTER();

    // Error thrown when a user tries to burn a booster that isnt theirs
    error NOT_YOUR_BOOSTER();

    // Error thrown if user has already minted a booster
    error ALREADY_MINTED();

    // Error thrown if the token address is not a contract
    error NOT_A_CONTRACT();
}