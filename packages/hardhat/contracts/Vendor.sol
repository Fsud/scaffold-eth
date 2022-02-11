// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable{

  YourToken yourToken;

  uint256 public tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);


  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  //ToDo: create a payable buyTokens() function:
  function buyTokens() public payable returns (uint256) {
    require(msg.value > 0, "Send ETH to buy some tokens");

    uint256 tokenAmount = msg.value * tokensPerEth;
    uint256 venderAmount = yourToken.balanceOf(address(this));
    
    require(venderAmount >= tokenAmount,"Vender Contract Amount not Enough");

    (bool sent) = yourToken.transfer(msg.sender, tokenAmount);
    require(sent, "Failed to buyToken");
    emit BuyTokens(msg.sender, msg.value, tokenAmount);
    return tokenAmount;
  }

  //ToDo: create a sellTokens() function:
  function sellTokens(uint256 amountToSell) public {
    require(amountToSell > 0, "amountToSell less than 0");
    uint256 balanceOfSender = yourToken.balanceOf(msg.sender);
    require(balanceOfSender >= amountToSell, "not enough tokens to sell");

    uint256 ethAmount = amountToSell/tokensPerEth;
    require(address(this).balance >= ethAmount, "vender not enough ETH");
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), amountToSell);
    require(sent, "tokensell failed");

    (bool sent2, ) = msg.sender.call{value:ethAmount}("");
    require(sent2, "tokensell failed");
    emit SellTokens(msg.sender, amountToSell, ethAmount);
  }

  //ToDo: create a withdraw() function that lets the owner, you can 
  //use the Ownable.sol import above:
  function withdraw() public onlyOwner {
    require(address(this).balance > 0, "no eth to withdraw");
    (bool sent,) = msg.sender.call{value:address(this).balance}("");
    require(sent, "withdraw failed");
  }
}
