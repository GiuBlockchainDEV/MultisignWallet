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

    struct proposal {
        uint idproposal;
        string textproposal;
        uint timeend;
        uint qty_vote;
        uint yes;
        uint no;
        bool ended;
        bool passed;}
    
    struct vote_weight {
        uint weight;
        string role;
        bool daomember;}

    uint public multisig = 10;
    uint public quorum = 2;
    uint private weight;
    uint public lastUpdated;
    uint public lastProposal;
    mapping(address => uint) private quantity;
    mapping(address => vote_weight) public daoweight;
    mapping (address => mapping (uint => bool)) voted;
    proposal[] private proposals;

    event received(address, uint);

    function setweight(address _addr, uint _weight, string memory _role, bool _member) public onlyOwner {
        daoweight[_addr].weight = _weight;
        daoweight[_addr].role = _role;
        daoweight[_addr].daomember = _member;}

    function getweight(address _addr) public view returns(uint, string memory, bool) {
        return(daoweight[_addr].weight, daoweight[_addr].role, daoweight[_addr].daomember);}

    function create_proposal(uint _timeend, string memory _propasal) public {
        require(daoweight[msg.sender].daomember == true, "Not a member of the DAO");
        proposals.push(proposal({idproposal: lastProposal, textproposal: _propasal, timeend: _timeend, qty_vote: 0, yes: 0, no: 0, ended: false, passed: false}));
        lastProposal = lastProposal + 1;}

    function read_proposal(uint _idproposal) public view returns(string memory, uint, uint, uint, uint, bool, bool) {
        uint i;
	    for(i=0;i<proposals.length;i++){
  		    proposal memory e = proposals[i];
  		    if(e.idproposal == _idproposal){
    			return(e.textproposal, e.timeend, e.qty_vote, e.yes, e.no, e.ended, e.passed);}}}

    function vote(uint _idproposal, uint _vote) public {
        require(daoweight[msg.sender].daomember == true, "Not a member of the DAO");
        require(proposals[_idproposal].qty_vote < multisig, "Proposal completed");
        require(voted[msg.sender][_idproposal] == false, "Voted");
        voted[msg.sender][_idproposal] = true;
        proposals[_idproposal].qty_vote += 1;
        weight = daoweight[msg.sender].weight;
        if(_vote == 0){proposals[_idproposal].no += 1 * weight;}
        if(_vote == 1){proposals[_idproposal].yes += 1 * weight;}
        if(proposals[_idproposal].qty_vote >= quorum){
            proposals[_idproposal].ended = true;
            if(proposals[_idproposal].yes > proposals[_idproposal].no){
                proposals[_idproposal].passed = true;}
            else{
                proposals[_idproposal].passed = false;}}}
    
    function transferERC20(address _tokenAddr, address _to, uint _amount) public onlyOwner nonReentrant {  
        require(new_type_IERC20(_tokenAddr).transfer(_to, _amount), "Could not transfer out tokens!");}

    function transferERC20O(address _tokenAddr, address _to, uint _amount) public onlyOwner nonReentrant {    
        old_type_IERC20(_tokenAddr).transfer(_to, _amount);}

    function updateTimestamp() public {
        lastUpdated = block.timestamp;}

    fallback() external payable {}

    receive() external payable {
        emit received(msg.sender, msg.value);}

    function transferEther(address _to, uint _amount) public onlyOwner nonReentrant {
        (bool os, ) = payable(_to).call{value: _amount}('');
        require(os);}}
