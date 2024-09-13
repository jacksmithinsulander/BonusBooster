// SPDX-License-Identifier: ISC
pragma solidity 0.8.27;

/* Solady Contracts */
import {ERC20} from "@solady/contracts/tokens/ERC20.sol";

contract MockToken is ERC20 {
    /// @dev Returns the name of the token.
    function name() public view override returns (string memory) {
        return "MockOp";
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view override returns (string memory) {
        return "MOP";
    }

    function mint(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }
}