// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

//Giuliano Neroni DEV
//https://www.giulianoneroni.com/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;}

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;}}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;}

    //Prevents a contract from calling itself, directly or indirectly.
    //Calling a `nonReentrant` function from another `nonReentrant`function is not supported. 
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;}}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        //dev Initializes the contract setting the deployer as the initial owner
        _transferOwnership(_msgSender());}

    function owner() public view virtual returns (address) {
        //Returns the address of the current owner
        return _owner;}

    modifier onlyOwner() {
        //Throws if called by any account other than the owner
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;}

    function renounceOwnership() public virtual onlyOwner {
        //Leaves the contract without owner
        _transferOwnership(address(0));}

    function transferOwnership(address newOwner) public virtual onlyOwner {
        //Transfers ownership of the contract to a new account (`newOwner`)
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);}

    function _transferOwnership(address newOwner) internal virtual {
        //Transfers ownership of the contract to a new account (`newOwner`)
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);}}

interface new_type_IERC20 {
    function transfer(address, uint) external returns (bool);}

interface old_type_IERC20 {
    function transfer(address, uint) external;}

contract MultisigDH is Ownable, ReentrancyGuard { 
    event deposit(address indexed sender, uint value);

    function transferAnyNewERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner nonReentrant {  
        require(new_type_IERC20(_tokenAddr).transfer(_to, _amount), "Could not transfer out tokens!");}

    function transferAnyOldERC20Token(address _tokenAddr, address _to, uint _amount) public onlyOwner nonReentrant {    
        old_type_IERC20(_tokenAddr).transfer(_to, _amount);}

    fallback() external payable {
        if (msg.value > 0)
            emit deposit(msg.sender, msg.value);}

    function transferEther(address _to, uint _amount) public onlyOwner nonReentrant {
        (bool os, ) = payable(_to).call{value: _amount}('');
        require(os);}}
