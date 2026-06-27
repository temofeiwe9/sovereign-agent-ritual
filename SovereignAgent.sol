// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SovereignAgent {
    address public owner;
    string public name;
    string public status = "Idle";
    uint256 public actionCount;
    uint256 public lastActionBlock;

    address constant RITUAL_AGENT_PRECOMPILE = 0x080C;

    event ActionPerformed(string action, string details, uint256 blockNumber);
    event RitualCallExecuted(string result);

    constructor(string memory _name) {
        owner = msg.sender;
        name = _name;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    function performAction(string memory _action, string memory _details) public onlyOwner {
        actionCount++;
        status = _action;
        lastActionBlock = block.number;
        emit ActionPerformed(_action, _details, block.number);
    }

    function executeRitualAction(string memory _prompt) public onlyOwner returns (string memory) {
        (bool success, bytes memory result) = RITUAL_AGENT_PRECOMPILE.call(abi.encode(_prompt));
        require(success, "Ritual Agent call failed");
        string memory response = abi.decode(result, (string));
        status = response;
        actionCount++;
        lastActionBlock = block.number;
        emit RitualCallExecuted(response);
        return response;
    }

    function getInfo() public view returns (string memory, string memory, uint256, uint256) {
        return (name, status, actionCount, lastActionBlock);
    }
}
