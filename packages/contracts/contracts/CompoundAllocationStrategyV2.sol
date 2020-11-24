pragma solidity 0.5.12;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {CErc20Interface} from "../compound/contracts/CErc20Interface.sol";
import {CompoundAllocationStrategy} from "./CompoundAllocationStrategy.sol";

/**
 * @notice CompoundAllocationStrategyV2 collects governance tokens from
 * Compound protocol and transfers them to a single address - compReceiver
 */
contract CompoundAllocationStrategyV2 is CompoundAllocationStrategy {

    event CompReceiverChanged(address indexed oldReceiver, address indexed newReceiver);

    // This variable is repeated because CompoundAllocationStrategy has private cToken
    CErc20Interface public cTokenContract;

    address public compReceiver;

    constructor(address cToken_, address compReceiver_) CompoundAllocationStrategy(cToken_)
      public {
          require(cToken_ != address(0), "cToken_ is zero address");
          require(compReceiver_ != address(0), "compReceiver_ is zero address");

          cTokenContract = CErc20Interface(cToken_);
          compReceiver = compReceiver_;
          emit CompReceiverChanged(address(0), compReceiver);
    }

    modifier auth() {
        require(msg.sender == compReceiver, "Caller is not the Comp Receiver");
        _;
    }

    function transferCompReceiverRights(address newReceiver) external auth {
        require(newReceiver != address(0), "newReceiver is zero address");

        emit CompReceiverChanged(compReceiver, newReceiver);
        compReceiver = newReceiver;
    }

    function claimComp() public {
        address comptroller = getComptrollerAddress();
        IComptroller(comptroller).claimComp(address(this));
    }

    function claimAndTransferComp() public {

        IComptroller comptroller = IComptroller(getComptrollerAddress());
        comptroller.claimComp(address(this));

        IERC20 compToken = IERC20(comptroller.getCompAddress());
        uint totalCompBalance = compToken.balanceOf(address(this));

        require(compToken.transfer(compReceiver, totalCompBalance), "token transfer failed");
    }

    function claimAndTransferComp(uint amount_) public {

        IComptroller comptroller = IComptroller(getComptrollerAddress());
        comptroller.claimComp(address(this));

        IERC20 compToken = IERC20(comptroller.getCompAddress());
        require(compToken.transfer(compReceiver, amount_), "token transfer failed");
    }

    function getComptrollerAddress() public view returns(address) {
        return cTokenContract.comptroller();
    }

}


contract IComptroller {
    function claimComp(address holder) public {}
    function getCompAddress() public view returns (address) {}
}
