// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Casino {
    //Declaration
    address owner;
    address player;
    bool coinResult;
    bool playerGuess;
    uint randNonce = 100;
    uint casinoBalance;
    uint playerAmount;
    uint gameState;
    uint public constant gameStopped = 0;
    uint public constant gameStarted = 1;
    uint public constant gameBetPlaced = 2;


    //Constructor
    constructor () {
        owner = msg.sender;
        casinoBalance = 0;
        gameState = gameStopped;
    }

    //The owner can deposit by this function
    function deposit() external payable {
        require (msg.sender == owner,'You are not the owner of the Casino.');
        casinoBalance += msg.value;
    }

    //The owner can withdraw by this function
    function withdraw (uint amount) public {
        require (msg.sender == owner,'You are not the owner of the Casino.');
        require(amount <= casinoBalance,'We do not have enough money in Casino.');
        require(gameState == gameStopped,'You have to wait until the end of the game.');
        address payable ownerAddress = payable(msg.sender);
        ownerAddress.transfer(amount);
    }

    //Function for satrting the game
    function startGame () public {
        require(msg.sender == owner,'You are not the owner of the Casino.');
        require(gameState == gameStopped,'You have a running game!!');
        randNonce++; 
        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % 850;
        if(randomNumber > 520) {
            coinResult = true;
        }
        else {
            coinResult = false;
        }
        gameState = gameStarted;
    }

    //You can play game by this function
    function play (bool guess) external payable {
        require(gameState == gameStarted,'We do not have any running game!');
        require(msg.value > 0,'You have to pay for playing.');
        player = msg.sender;
        playerAmount = msg.value;
        casinoBalance += msg.value;
        playerGuess = guess;
        gameState = gameBetPlaced;
    }

    //Function for ending the game
    function endGame () public {
        require (msg.sender == owner,'You are not the owner of the Casino.');
        require(gameState == gameBetPlaced,'This game is already ended.');
        if(gameState == gameBetPlaced) {
            if(playerGuess == coinResult) {
                address payable playerAddress = payable(msg.sender);
                playerAddress.transfer((10*playerAmount)/100);
                casinoBalance -= ((10*playerAmount)/100);
                gameState = gameStopped;
            }
            else {
                gameState = gameStarted;
            }
        }
    }

    //The owner can see the coin result
    function getCoinResult () public view returns (bool result){
        require(msg.sender == owner,'You are not the owner of the Casino.');
        return coinResult;
    }

    //this function enables the contract to receive funds
    receive () external payable {
    }
}
