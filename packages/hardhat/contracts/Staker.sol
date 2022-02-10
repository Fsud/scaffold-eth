// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping (address=>uint256) balances;

  uint256 constant threshold = 1 ether;

  uint256 public deadline = block.timestamp + 120 seconds;

  event Stake(address,uint256);

  modifier stakeNotCompleted(){
    bool complete = exampleExternalContract.completed();
    require(!complete, "HAS COMPLETED");
    _;
  }

  modifier deadlineReached(bool requireReach){
    uint256 timeleft = timeLeft();
    if(requireReach){
      require(timeleft == 0,"DEADLINE NOT REACH");
    }else{
      require(timeleft > 0, "DEADLINE HAS REACH");
    }
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable deadlineReached(false) stakeNotCompleted {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  } 


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public deadlineReached(false) stakeNotCompleted {
    uint256 contractBalance = address(this).balance;

    //require(!exampleExternalContract.completed, "HAS COMPLETE");
    require(contractBalance >= threshold ,"THRESHOLD NOT REACHED");
    //exampleExternalContract.complete{value:address(this).balance}();
    (bool sent,) = address(exampleExternalContract).call{value:contractBalance}(abi.encodeWithSignature("complete()"));
    require(sent,"EXECUTE FAILED");
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  //取款的条件是，质押已达到阈值，且未结束
  function withdraw(address addrezz) public deadlineReached(true) stakeNotCompleted {
    require(addrezz == msg.sender);
    uint256 userBalance = balances[msg.sender];
    require(userBalance > 0, "You don't have balance to withdraw");

    balances[msg.sender] = 0;

    (bool sent,) = msg.sender.call{value:userBalance}("");
    require(sent, "FAILED TO WITHDRAW");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256 timeleft) {
    if(block.timestamp >= deadline){
      return 0;
    }else{
      return deadline - block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()


}
