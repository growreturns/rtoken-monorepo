pragma experimental ABIEncoderV2;
pragma solidity >=0.5.10 <0.6.0;

import { RToken, IAllocationStrategy } from "../RToken.sol";

/**
 * @notice RToken instantiation for rSAI (Redeemable SAI)
 */
contract rDAI is RToken {

    function initialize (
        IAllocationStrategy allocationStrategy) external {
        RToken.initialize(allocationStrategy,
            "Grow DAI",
            "gDAI",
            18);
    }

}
