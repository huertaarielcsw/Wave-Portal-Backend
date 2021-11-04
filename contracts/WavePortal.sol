// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    mapping(address => uint256) wavePerUser;
    mapping(address => uint256) public lastWavedAt;
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(
        address indexed from,
        uint256 timestamp,
        string message,
        string won
    );

    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    Wave[] waves;

    constructor() payable {
        console.log("Kekeke, It's me perorin");
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 5 minutes < block.timestamp,
            "Must wait 5 minutes before waving again."
        );

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));
        wavePerUser[msg.sender] += 1;
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated", seed);
        string memory won = "";
        if (seed <= 50) {
            console.log("%s won!", msg.sender);
            won = "yes";
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        } else {
            won = "no";
        }

        emit NewWave(msg.sender, block.timestamp, _message, won);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    function getTotalWavesPerUser() public view returns (uint256) {
        console.log(
            "User has send us %d total waves!",
            wavePerUser[msg.sender]
        );
        return wavePerUser[msg.sender];
    }
}
