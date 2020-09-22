pragma experimental ABIEncoderV2;
pragma solidity >=0.5.10 <0.6.0;

import { RToken } from "../RToken.sol";

/**
 * @notice RToken instantiation for rSAI (Redeemable SAI)
 */
contract rSAI is RToken {

    function updateTokenInfo()
        external
        onlyOwner {
        name = "Redeemable SAI";
        symbol = "rSAI";
    }

}
