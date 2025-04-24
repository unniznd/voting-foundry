// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";

contract VotingTest is Test {
    Voting private voting;

    address[] private candidates;
    uint256 private startTime;
    uint256 private endTime;

    function setUp() public {
        voting = new Voting();

        candidates = new address[](2);
        candidates[0] = address(1);
        candidates[1] = address(2);
        startTime = block.timestamp + 100;
        endTime = startTime + 200;
    }

    function testGetTotalElections() public view {
        assertEq(voting.getTotalElections(), 0);
    }

    function testCreateElection() public {
        vm.prank(address(this));
        voting.createElection({candidates: candidates, startTime: startTime, endTime: endTime});

        Voting.Election memory election = voting.getElectionById({_id: 0});

        assertEq(election.electionId, 0);
        assertEq(election.addr.length, 2);
        assertEq(election.addr[0], address(1));
        assertEq(election.addr[1], address(2));
        assertEq(election.votes.length, 2);
        assertEq(election.votes[0], 0);
        assertEq(election.votes[1], 0);
        assertEq(election.startTime, startTime);
        assertEq(election.endTime, endTime);
    }

    function testCreateElectionNotOwner() public {
        vm.prank(address(1));
        vm.expectRevert();
        voting.createElection({candidates: candidates, startTime: startTime, endTime: endTime});
    }

    function testCreateElectionEndTimeLessThanStartTime() public {
        vm.prank(address(this));
        vm.expectRevert();
        voting.createElection({candidates: candidates, startTime: block.timestamp + 10, endTime: block.timestamp + 5});
    }

    function testCreateElectionNoCandidate() public {
        vm.prank(address(this));
        vm.expectRevert();

        voting.createElection({candidates: new address[](0), startTime: startTime, endTime: endTime});
    }

    function testCastVote() public {
        vm.prank(address(this));
        voting.createElection({candidates: candidates, startTime: block.timestamp, endTime: block.timestamp + 1000000});

        address voter = address(0x123);
        vm.prank(voter);
        voting.castVote(0, address(1));

        Voting.Election memory election = voting.getElectionById({_id: 0});
        assertEq(election.votes[0], 1);
        assertEq(election.votes[1], 0);
    }

    function testCastVoteInvalidElection() public {
        vm.prank(address(0x123));
        vm.expectRevert();
        voting.castVote(1, address(1));
    }

    function testCastVoteElectionNotStarted() public {
        vm.prank(address(this));
        voting.createElection({
            candidates: candidates,
            startTime: block.timestamp + 1000,
            endTime: block.timestamp + 1000000
        });

        address voter = address(0x123);
        vm.prank(voter);
        vm.expectRevert();
        voting.castVote(0, address(1));
    }

    function testCastVoteElectionFinished() public {
        vm.prank(address(this));
        voting.createElection({candidates: candidates, startTime: 0, endTime: 1});

        address voter = address(0x123);
        vm.prank(voter);
        vm.expectRevert();
        voting.castVote(0, address(1));
    }

    function testCastVoteAlreadyVoted() public {
        vm.prank(address(this));
        voting.createElection({candidates: candidates, startTime: block.timestamp, endTime: block.timestamp + 1000000});

        address voter = address(0x123);
        vm.prank(voter);
        voting.castVote(0, address(1));

        Voting.Election memory election = voting.getElectionById({_id: 0});
        assertEq(election.votes[0], 1);
        assertEq(election.votes[1], 0);

        vm.prank(voter);
        vm.expectRevert();
        voting.castVote(0, address(1));
    }

    function testCastVoteCandidateInvalidAdress() public {
        vm.prank(address(this));
        voting.createElection({candidates: candidates, startTime: block.timestamp, endTime: block.timestamp + 1000000});

        address voter = address(0x123);
        vm.prank(voter);
        vm.expectRevert();
        voting.castVote(0, address(0));
    }

    function testCastVoteCandidateDoesNotExist() public {
        vm.prank(address(this));
        voting.createElection({candidates: candidates, startTime: block.timestamp, endTime: block.timestamp + 1000000});

        address voter = address(0x123);
        vm.prank(voter);
        vm.expectRevert();
        voting.castVote(0, address(3));
    }

    function testGetOwner() public view {
        assertEq(voting.getOwner(), address(this));
    }
}
