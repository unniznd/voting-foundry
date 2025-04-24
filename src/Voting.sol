// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract Voting {
    struct Election {
        uint256 electionId;
        address[] addr;
        uint256[] votes;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(uint256 => Election) private s_elections;
    mapping(uint256 => mapping(address => bool)) private s_isVoted;

    address private s_owner;
    uint256 private s_totalElection;

    event ElectionCreated(uint256 electionId, uint256 startTime, uint256 endTime);
    event VoteCasted(uint256 indexed electionId, address indexed voter, address indexed candidate);

    modifier onlyOwner() {
        require(msg.sender == s_owner, "Only owner can call");
        _;
    }

    constructor() {
        s_owner = msg.sender;
        s_totalElection = 0;
    }

    function createElection(address[] calldata candidates, uint256 startTime, uint256 endTime) public onlyOwner {
        require(endTime > startTime, "End time must be greater than start time");
        require(candidates.length > 0, "Minimum one candidate is required");
        s_elections[s_totalElection] = Election({
            electionId: s_totalElection,
            addr: candidates,
            votes: new uint256[](candidates.length),
            startTime: startTime,
            endTime: endTime
        });

        s_totalElection++;

        emit ElectionCreated({electionId: s_totalElection, startTime: startTime, endTime: endTime});
    }

    function castVote(uint256 _id, address _candidate) public {
        require(_id >= 0 && _id <= s_totalElection, "Invalid election ID");

        Election storage election = s_elections[_id];
        require(block.timestamp >= election.startTime, "Election not started");
        require(block.timestamp < election.endTime, "Election has ended");

        require(!s_isVoted[_id][msg.sender], "Already voted");

        require(_candidate != address(0), "Invalid candidate address");
        uint256 candidateLength = election.addr.length;

        uint256 candidateIdx = type(uint256).max;
        for (uint256 idx = 0; idx < candidateLength; idx++) {
            if (election.addr[idx] == _candidate) {
                candidateIdx = idx;
                break;
            }
        }
        require(candidateIdx != type(uint256).max, "Candidate not found");

        election.votes[candidateIdx]++;
        s_isVoted[_id][msg.sender] = true;

        emit VoteCasted(_id, msg.sender, _candidate);
    }

    function getTotalElections() external view returns (uint256) {
        return s_totalElection;
    }

    function getElectionById(uint256 _id) external view returns (Election memory) {
        return s_elections[_id];
    }

    function getOwner() external view returns (address) {
        return s_owner;
    }
}
