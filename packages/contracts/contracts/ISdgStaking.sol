pragma solidity 0.5.12;

interface ISdgStaking {
    function stake(address user, uint amount) external;
    function withdraw(address user, uint amount) external;
}
