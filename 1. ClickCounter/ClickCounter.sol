// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract ClickCounter {
    uint256 public counter;

    function click() public {
        counter++;
    }
    
    function decrement() public {
        if (counter > 0){
            counter--;
        }
    }

    function reset() public {
        counter = 0;
    }
}
