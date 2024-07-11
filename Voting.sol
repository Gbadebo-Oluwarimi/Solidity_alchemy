// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
    }
    event ProposalCreated(uint proposalId);
    event VoteCast (uint proposalId, address _voteAddress);
    error UsernotinArray();
    address[] public addr;
    Proposal[] public proposals;
    mapping(address => bool) public alreadyVoted; //mapping individual targets to a boolean 
    // to check if they've voted or not
    constructor (address[] memory _addr ){
       addr = _addr;
       addr.push(msg.sender);
    }
    function newProposal(address _targetAddr, bytes calldata _data) external {
        // check if address is in the address array 
        bool _isaddr = checkAddress(msg.sender);
        if(_isaddr){
             Proposal memory _proposal = Proposal(_targetAddr,_data,0,0);
            proposals.push(_proposal);
            emit ProposalCreated(proposals.length - 1);
        }
        else{
            revert UsernotinArray();
        }
    }
    function castVote(uint proposalId, bool _inSupport) external {
        //checks if the address exists in the array
        bool _isaddr = checkAddress(msg.sender);
        if(_isaddr){
        Proposal storage _isSuccess = proposals[proposalId];
        //allow already voted users to change their votes 
        // if a user hasn't voted (bool == false)
       if(!alreadyVoted[msg.sender]){
        if(_inSupport){
            _isSuccess.yesCount += 1;
        }
        else{
         _isSuccess.noCount += 1;
       
        }
        // after running the flow above it then updates the user alreadyVoted to true
        emit VoteCast(proposalId, msg.sender);
        alreadyVoted[msg.sender] = true;
       }
       // if a user has alredy voted we call the change vote function 
       else{
            changeVote(_isSuccess, _inSupport);
            emit VoteCast(proposalId, msg.sender);
       }
    }else{
        revert UsernotinArray();
    }
       
    }
    function changeVote(Proposal storage _datap, bool _support) internal {
        if (_support) {
           if (_datap.noCount > 0) {
                _datap.noCount -= 1;
            }
            _datap.yesCount += 1;
        } 
        else {
           if (_datap.yesCount > 0) {
                _datap.yesCount -= 1;
            }
            _datap.noCount += 1;
        }
       
    
    }
    function checkAddress(address _checkaddr) internal returns(bool) {
        for(uint i = 0; i < addr.length;i++){
            if(addr[i] == _checkaddr){
                return true;
            }
        }
        return false;
    }
}
