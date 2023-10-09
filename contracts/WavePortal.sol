pragma solidity ^0.8.0;

import "hardhat/console.sol";


/*
 * @author: marco.nascimento
 * Stores simple interactions with the front end
 * and performs a raffle
 *
 * It's my first smart contract.
 *
 * Important lessions learned: Contract is immutable, so we need that any change will be made a new deploy/contract of the changed contract
 * Think Functionally program like Events, Observables...
  */
contract WavePortal {
    
    uint256 private seed;
    uint256 totalWaves;
    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    event NewWave(address indexed from, uint256 timestamp, string message);

    constructor() payable {
        seed = (block.timestamp + block.difficulty) % 100;
    }

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    function wave(string memory _message) public {

        waveValidation();

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        waves.push(Wave(msg.sender, _message, block.timestamp));
        console.log("%s tchauzinhou!", msg.sender);

        prizeDraw();

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function waveValidation() private { 
        require(
            lastWavedAt[msg.sender] + 5 seconds < block.timestamp,
            "wait 5 seconds"
        );
    }

    function prizeDraw() private {
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("seed:", seed);

        if (seed <= 50) {
            console.log("%s winner!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;

            require(
                prizeAmount <= address(this).balance,
                "Insuficient balance"
            );

            (bool success, ) = (msg.sender).call{ value: prizeAmount }("");

            require(success, "Failed to withdaw money from contract");
        }
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }

    function appendString(string memory _a, string memory _b) internal pure returns (string memory)  {
        return string(abi.encodePacked(_a, _b));
    }
}