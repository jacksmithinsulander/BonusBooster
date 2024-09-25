// SPDX-License-Identifier: ISC
pragma solidity 0.8.27;

/**
 * @title Bonus Errors
 * @notice Library to manage errors in the Bonus contract
 * @author https://x.com/0xjsieth
 *
 */
library BonusErrors{
    // Error thrown if user is not on whitelist
    error YOU_ARE_NOT_ON_THE_WHITELIST();

    // Error thrown if user does not own any boosters
    error YOU_DONT_OWN_ANY_BOOSTER();

    // Error thrown when a user tries to burn a booster that isnt theirs
    error NOT_YOUR_BOOSTER();

    // Error thrown if user has already minted a booster
    error ALREADY_MINTED();

    // Error thrown if the token address is not a contract
    error NOT_A_CONTRACT();

    // Error thrown if user about to get whitelisted is a contract address
    error CANT_WHITELIST_CONTRACTS();

    // Error if already whitelisted
    error ALREADY_WHITELISTED();
}