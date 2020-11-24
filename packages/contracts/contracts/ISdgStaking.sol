pragma solidity ^0.5.8;

interface ISdgStaking {
    function stake(address user, uint amount) external;
    function withdraw(address user, uint amount) external;
}
