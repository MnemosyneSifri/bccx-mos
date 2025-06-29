// SPDX-License-Identifier: AGPL-3.0
// Copyright (c) 2025 Mnemosyne Sifri
pragma solidity ^0.8.21;

/**
 * @title MoralKernel
 * @author Mnemosyne Sifri
 * @notice Core contract of the BCCXGenesis Moral Operating System (MOS)
 * @dev Tracks moral agents, their virtue metrics, cofungs, and dispute history.
 */
contract MoralKernel {
    // Enum to represent different virtue types, more gas-efficient than strings.
    enum VirtueType {
        Prudence,
        Justice,
        Fortitude,
        Temperance,
        Creativity,
        PublicGiving,
        // Add more virtues here if needed
        UNKNOWN // Sentinel value for safety, though not strictly needed if handled well
    }

    struct VirtueScores {
        uint256 prudence;
        uint256 justice;
        uint256 fortitude;
        uint256 temperance;
        uint256 creativity;
        uint256 publicGiving;
    }

    struct MoralAgent {
        bool registered;
        VirtueScores virtues;
        uint256 cofungs;
        uint256 characterScore;
        uint256 lastUpdated;
    }

    // Mapping to store agent data
    mapping(address => MoralAgent) public agents;

    // The contract owner, set once in the constructor and immutable.
    address public immutable owner;

    // Modifier to restrict access to only the contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    // --- Events ---
    event AgentRegistered(address indexed agent); // indexed for easier filtering off-chain
    event VirtueUpdated(address indexed agent, VirtueType indexed virtueType, uint256 newScore); // indexed for filtering
    event CofungUpdated(address indexed agent, uint256 newCofung); // indexed for filtering
    event CharacterScoreUpdated(address indexed agent, uint256 newScore); // indexed for filtering

    // --- Constructor ---
    constructor() {
        owner = msg.sender;
    }

    // --- Agent Management Functions ---

    function registerAgent(address agent) external onlyOwner {
        require(!agents[agent].registered, "Agent already registered");
        agents[agent].registered = true;
        agents[agent].lastUpdated = block.timestamp;
        emit AgentRegistered(agent);
    }

    function updateVirtue(address agent, VirtueType virtueType, uint256 newScore) external onlyOwner {
        require(agents[agent].registered, "Agent not registered");
        require(virtueType != VirtueType.UNKNOWN, "Invalid virtue type");

        if (virtueType == VirtueType.Prudence) {
            agents[agent].virtues.prudence = newScore;
        } else if (virtueType == VirtueType.Justice) {
            agents[agent].virtues.justice = newScore;
        } else if (virtueType == VirtueType.Fortitude) {
            agents[agent].virtues.fortitude = newScore;
        } else if (virtueType == VirtueType.Temperance) {
            agents[agent].virtues.temperance = newScore;
        } else if (virtueType == VirtueType.Creativity) {
            agents[agent].virtues.creativity = newScore;
        } else if (virtueType == VirtueType.PublicGiving) {
            agents[agent].virtues.publicGiving = newScore;
        }

        agents[agent].lastUpdated = block.timestamp;
        emit VirtueUpdated(agent, virtueType, newScore);
        recalculateCharacterScore(agent);
    }

    function updateCofungs(address agent, uint256 newCofung) external onlyOwner {
        require(agents[agent].registered, "Agent not registered");
        agents[agent].cofungs = newCofung;
        agents[agent].lastUpdated = block.timestamp;
        emit CofungUpdated(agent, newCofung);
    }

    function recalculateCharacterScore(address agent) public onlyOwner {
        VirtueScores memory v = agents[agent].virtues;
        uint256 total = v.prudence + v.justice + v.fortitude + v.temperance + v.creativity + v.publicGiving;
        agents[agent].characterScore = total;
        agents[agent].lastUpdated = block.timestamp;
        emit CharacterScoreUpdated(agent, total);
    }

    function getVirtueScores(address agent) external view returns (VirtueScores memory) {
        return agents[agent].virtues;
    }

    function getCharacterScore(address agent) external view returns (uint256) {
        return agents[agent].characterScore;
    }

    function getCofungs(address agent) external view returns (uint256) {
        return agents[agent].cofungs;
    }
}