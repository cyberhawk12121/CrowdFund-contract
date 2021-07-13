//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import 'https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Project{
    using Safemath for uint256;
    
    enum Fundingstage{
        Raising, 
        Expired,
        Successful
    }

    address payable creator;
    uint public goalAmount;
    uint public deadLine;
    uint public completeAt; // time when goalAmount is reached
    uint public currentBalance;
    string public title;
    string public description;
    string public title;
    
    Fundingstage public stage= Fundingstage.Raising;    // initialised at Raising stage
    mapping(address=>uint) public contributions;

    event ReceivedFund(address contributer, uint amount, uint currentTotal);
    event CreatorPaid(address recipient);
    event FundCompleted(bool success, uint completionTime); 
    event ProjectExpired(bool failed);  // failed=true, if expired

    modifier stageOfFunding(State _stage){
        require(stage==_stage);
        _;
    }
    modifier isCreator(){
        require(msg.sender==creator);
        _;
    }

    constructor(
        address payable projectCreator,
        string memory _title,
        string memory _description,
        uint _deadline,
        uint _goalAmount
    ){
        creator=projectCreator;
        title= _title;
        description=_description;
        goalAmount=_goalAmount;
        deadLine= _deadline;
        currentBalance=0;
    }

    function fundProject() external stageOfFunding(Fundingstage.Raising) payable{
        require(msg.sender!= creator);  
        require(msg.value<=0,"Fund  amount cannot be less than 0");
        contributions[msg.sender]=contributions[msg.sender].add(msg.value);
        currentBalance=currentBalance.add(msg.value);
        emit ReceivedFund(msg.sender, msg.value, currentBalance);
        checkIfFundsCompleteOrExpired();
    }

    function checkIfFundsCompleteOrExpired() public{
        if(currentBalance>=amountGoal){
            stage=Fundingstage.Successful;
            emit FundCompleted(true, block.timestamp);
            payProject();
        }
        else if(block.timestamp>deadLine){
            stage=Fundingstage.Expired;
            emit ProjectExpired(true);
        }
        completeAt=block.timestamp;
    }

    function payProject() internal stageOfFunding(Fundingstage.Successful){
        uint256 totalRaised= currentBalance;
        currentBalance=0;
        msg.sender.transfer(totalRaised);
        emit CreatorPaid(creator);
    }
    
    function refund() public isCreator stageOfFunding(Fundingstage.Expired) returns (bool){
        require(contributions[msg.sender]>0);
        uint256 amountToRefund= contributions[msg.sender];
        if(!msg.sender.send(amountToRefund)){
            contributions[msg.sender]=amountToRefund;
            return false;
        }else{
            currentBalance=currentBalance.sub(amountToRefund);
        }
        return true;
    }

    function updateProject(uint _deadLine, string memory _description) public isCreator{
        // require(_goalAmount>0 && _goalAmount!=goalAmount);
        // goalAmount=_goalAmount;
        description= _description;
        deadLine= _deadLine;
    }

    function getDetails() public view returns(
        address payable projectCreator,
        string memory projectTitle,
        string memory projectDescription,
        uint projectDeadline,
        State currentStage,
        uint currentAmount,
        uint goalAmt
        ){
            projectCreator=creator;
            projectTitle=title;
            projectDescription=description;
            projectDeadline=deadLine;
            currentStage=stage;
            currentAmount=currentBalance;
            goalAmt=goalAmount;
        }
}

contract Fundraiser{
    // state variables
    using Safemath for uint256;

    mapping(address=>Project) projectsCreated;
    Project[] private projects;
    event Initiation(address startedBy, string projectName, string description,uint goalAmount, uint deadline);    

    constructor(){
        
    }

    // function to create a project
    function createProject(
        string memory title, string memory description, uint durationInDays, uint goalAmount
    ) external{
        uint deadLine= now.add(durationInDays.mul(1 days));
        Project newProject= new Project(msg.sender, title, description, deadLine, goalAmount);
        projects.push(newProject);
        emit Initiation(msg.sender, title, description, goalAmount, deadLine);
    }

    function returnProjects() public view returns(Project[] memory){
        return projects;
    }

}