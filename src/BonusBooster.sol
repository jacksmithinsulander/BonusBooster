// SPDX-License-Identifier: ISC
pragma solidity 0.8.27;

/* Solady Contracts */
import {ERC721} from "@solady/contracts/tokens/ERC721.sol";

/* Solady Libraries */
import {Ownable} from "@solady/contracts/auth/Ownable.sol";
import {LibString} from "@solady/contracts/utils/LibString.sol";

/* Bonus Libraries */
import {BonusErrors} from "src/libraries/BonusErrors.sol";
import {BonusEvents} from "src/libraries/BonusEvents.sol";
import {ContractCheck} from "src/libraries/ContractCheck.sol";

/**
 * @title Bonus Booster
 * @notice Minting contract to manage users boost
 * @author https://x.com/0xjsieth
 *
 */
contract BonusBooster is ERC721, Ownable {
    // Uint to string conversion library
    using LibString for uint256;

    // Check if address is a contract
    using ContractCheck for address;

    //     _____ __        __
    //    / ___// /_____ _/ /____  _____
    //    \__ \/ __/ __ `/ __/ _ \/ ___/
    //   ___/ / /_/ /_/ / /_/  __(__  )
    //  /____/\__/\__,_/\__/\___/____/

    // Base uri for nft hosting
    string private baseUri;

    // current minting index, this will keep incrementing
    uint256 private currentIndex = 1;

    // Mapping as a way to keep track of if a user has minted
    mapping(address holder => bool status) public mintStatusOf;

    // Mapping to keep track of how many times a user boosted
    mapping(address holder => uint8 boostedAmounts) public boostsOf;

    // Mapping to keep track of whitelisting
    mapping(address person => bool status) public whitelist; 

    //     ______                 __                  __
    //    / ____/___  ____  _____/ /________  _______/ /_____  _____
    //   / /   / __ \/ __ \/ ___/ __/ ___/ / / / ___/ __/ __ \/ ___/
    //  / /___/ /_/ / / / (__  ) /_/ /  / /_/ / /__/ /_/ /_/ / /
    //  \____/\____/_/ /_/____/\__/_/   \__,_/\___/\__/\____/_/

    /**
     * @notice
     *  Constructor for Bonus Booster contract, sets some global variables
     *
     * @param _baseUri Base Uri for hosted token info
     *
     */
    constructor (string memory _baseUri) {
        // Set base uri
        baseUri = _baseUri;

        // Set deployer as owner
        _initializeOwner(msg.sender);
    }

    //      ____        __    ___         ______                 __  _                 
    //     / __ \__  __/ /_  / (_)____   / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / /_/ / / / / __ \/ / / ___/  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / ____/ /_/ / /_/ / / / /__   / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  ) 
    //  /_/    \__,_/_.___/_/_/\___/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /**
     * @notice 
     *  Returns the token collection name.
     *
     * @return the name of the token.
     *
     */
    function name() public pure override returns (string memory) {
        return "Bonus Booster";
    }

    /**
     * @notice 
     *  Returns the token collection symbol.
     *
     * @return the ticker of the token.
     *
     */
    function symbol() public pure override returns (string memory) {
        return "BB";
    }

    /**
     * @notice 
     *  Returns the Uniform Resource Identifier (URI) for token `id`.
     *
     * @param id id of token we want to look up
     *
     * @return Return associated tokenURI 
     *
     */
    function tokenURI(uint256 id) public view override returns (string memory) {
        // Concatenating strings, designed this way in order to having the baseUri upgradable
        return string.concat(baseUri, id.toString());
    }

    //      ______     __                        __   ______                 __  _
    //     / ____/  __/ /____  _________  ____ _/ /  / ____/_  ______  _____/ /_(_)___  ____  _____
    //    / __/ | |/_/ __/ _ \/ ___/ __ \/ __ `/ /  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //   / /____>  </ /_/  __/ /  / / / / /_/ / /  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  /_____/_/|_|\__/\___/_/  /_/ /_/\__,_/_/  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

    /**
     * @notice
     *  Minting function for the booster
     *
     */
    function mintBooster() external {
        // Check if user is on whitelist
        if (!whitelist[msg.sender]) revert BonusErrors.YOU_ARE_NOT_ON_THE_WHITELIST();

        // Check if user has already minted a booster, if so, revert
        if (mintStatusOf[msg.sender]) revert BonusErrors.ALREADY_MINTED();

        // Unchecked to save gas
        unchecked {
            // Mint the booster 
            _mint(msg.sender, currentIndex);

            // Increment the current index
            currentIndex++;

            // Set mintstatus
            mintStatusOf[msg.sender] = true;
        }
    }

    /**
     * @notice
     *  Function to use the booster, this call will result in buring the token and setting the user as boosted
     *
     * @param _id id of token we want to use for boost
     *
     */
    function boost(uint256 _id) external {
        // Check if user has any boosters, if not, revert
        if (balanceOf(msg.sender) < 1) revert BonusErrors.YOU_DONT_OWN_ANY_BOOSTER();

        if (ownerOf(_id) != msg.sender) revert BonusErrors.NOT_YOUR_BOOSTER();

        // Burn the booster
        _burn(_id);

        // Increment boosts of
        boostsOf[msg.sender]++;

        // Emit event with relevant info
        emit BonusEvents.Boost(msg.sender, boostsOf[msg.sender], _id);
    }

    //     ____        __         ____                              ______                 __  _
    //    / __ \____  / /_  __   / __ \_      ______  ___  _____   / ____/_  ______  _____/ /_(_)___  ____  _____
    //   / / / / __ \/ / / / /  / / / / | /| / / __ \/ _ \/ ___/  / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
    //  / /_/ / / / / / /_/ /  / /_/ /| |/ |/ / / / /  __/ /     / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
    //  \____/_/ /_/_/\__, /   \____/ |__/|__/_/ /_/\___/_/     /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/
    //               /____/

    /**
     * @notice
     *  For emergencies, allows the deployer to switch the uri base link in case it is needed in order to
     *  not mess up the contract perpetually in case a server goes down or something
     *
     * @param _newBaseUri a string of the new base uri link
     *
     */
    function resetBaseUri(string memory _newBaseUri) external onlyOwner {
        baseUri = _newBaseUri;
    }

    /**
     * @notice
     *  Function to toggel whitelist. I did a toggle design so that the plattform have control
     *  to blacklist whitelisted wallets if they so choose to do so
     *
     * @param _user the persons wallet we are about to toggle
     * @param _status the status we are about to set associated with the wallet
     *
     */
    function toggleWhitelist(address _user, bool _status) external onlyOwner() {
        // Make sure that user isnt contract
        if (_user.isContract()) revert BonusErrors.CANT_WHITELIST_CONTRACTS();

        // Make sure user isnt already whitelisted
        if (whitelist[_user] && _status) revert BonusErrors.ALREADY_WHITELISTED();

        unchecked {
            whitelist[_user] = _status;
        }
    }
}
