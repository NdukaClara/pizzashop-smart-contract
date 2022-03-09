// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

contract PizzaShop {
    address public owner;

    // cost for normal pizza
    uint256 public normalCost = 0.2 ether;

    // cost for sausage pizza
    uint256 public sausageCost = 0.3 ether;

    // time of opening
    uint256 public startDate = block.timestamp + 2 minutes;
    
    mapping (address => uint256) public userRefunds;
    bool public paused = false;

    event BoughtPizza(address indexed _from, uint256 cost);

    // pizza stages
    enum Stages {
        readyToOrder,
        makePizza,
        deliverPizza
    }

    Stages public pizzaShopStage = Stages.readyToOrder;

    constructor() {
        owner = msg.sender;
    }

    // checks if pizza shop is opened before placing order
    modifier shopOpened() {
        require(block.timestamp > startDate, "Not opened yet!");
        _;
    }

    // checks if its the owner that wants to refund
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner!");
        _;
    }

    // checks if a customer has the correct amount
    modifier correctAmount() {
        require(msg.value == normalCost || msg.value == sausageCost,  "Not the correct amount!");
        _;
    }

    // checks if 
    modifier isAtStage(Stages _stage) {
        require(pizzaShopStage == _stage, "Not at correct stage!");
        _;
    }

    modifier notPaused() {
        require(paused == false);
        _;
    }

    // checks if 
    function buyPizza(uint256 _price) payable public correctAmount() isAtStage(Stages.readyToOrder) shopOpened notPaused{
        updateStage(Stages.makePizza);
        emit BoughtPizza(msg.sender, _price);
    }


    function refund(address _to, uint256 _cost) payable public onlyOwner correctAmount(){
        require(address(this).balance >= _cost, "Not enough funds!");

        userRefunds[_to] = _cost;

    }

    // this is a pull refund function. allows the customer to claim their refund
    function claimRefund() payable public {
        uint256 value = userRefunds[msg.sender];

        userRefunds[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: value}("");
        require(success);
    } 


    function getFunds() public view returns(uint256){
        return address(this).balance;
    }
    // checks if 
    function madePizza() public isAtStage(Stages.makePizza) shopOpened{
        updateStage(Stages.deliverPizza);
    }

    // checks if pizza is at the delivery stage then calls the order stage
    function pickupPizza() public isAtStage(Stages.deliverPizza) shopOpened{
        updateStage(Stages.readyToOrder);
    }

    // 
    function updateStage(Stages _stage) public {
        pizzaShopStage = _stage;
    }

    // 
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

}