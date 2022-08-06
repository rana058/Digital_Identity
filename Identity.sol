// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
contract Identity {
    
    bytes4 public uniqueId;  // generated using keccak256(email,mobileNo)
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    
    struct User {
        string name;
        string email;
        uint64 mobileNo;
        string country;
        string dob;
    }
    mapping(bytes4 => User) public users; // uniqueId to struct User mapping
    mapping(string => bool) public verifiedEmail;  
    mapping(uint64 => bool) public verifiedMobileNo;
    mapping(uint64 => bool) public uniqueMobileNo;
    mapping(string => bool) public uniqueEmail;
    mapping(bytes4 => bytes4) public emailOTP; //uniqueId to hashed emailOTP mapping
    mapping(bytes4 => bytes4) public mobileOTP; //uniqueID to hashed mobileOTP mapping
    mapping(address => uint) public rewards;  // address to rewards mapping
    mapping(address => bytes4) public walletdata; // address to uniquId mapping

    bytes4[] public userArray; // array stores all uniqueIds
    
    
    modifier onlyOwner {
       require(msg.sender == owner);
       _;
    }
    
    // rewards function
    function rewarduser() public {
        rewards[msg.sender] +=1;
    }

    // generating uniqueId and creating identity of a user
    function createIdentity(string memory _name, string memory _email, uint64 _mobileNo, string memory _country, string memory _dob) public onlyOwner {
        require(uniqueEmail[_email] != true, "Need another email" );
        require(uniqueMobileNo[_mobileNo] != true, "Need another email" );

        uniqueId = bytes4(keccak256(abi.encodePacked(_email, _mobileNo)));
        users[uniqueId] = User(_name, _email, _mobileNo, _country, _dob);
        walletdata[msg.sender] = uniqueId;
        userArray.push(uniqueId);
        uniqueEmail[_email] = true;
        uniqueMobileNo[_mobileNo] = true;
        rewarduser();
    }

    //get Email OTP from backend
    function getEmailOTP(bytes4 _uniqueId, uint _eotp) external {
        emailOTP[_uniqueId] = bytes4(keccak256(abi.encodePacked(_eotp)));
    }
    //get Mobile OTP from backend
    function getMobileOTP(bytes4 _uniqueId, uint _motp) external {
         mobileOTP[_uniqueId] =  bytes4(keccak256(abi.encodePacked(_motp)));
    }

    //Verifying user email using OTP. comapring OTP hash stored in blockchain with OTP user received

    function verifyUserByEmail(bytes4 _uniqueId, string memory _email, uint _otp) public onlyOwner returns (bool isVerified){
        require(uniqueEmail[_email] == true, "Need unique Email");
        require(keccak256(abi.encodePacked(users[_uniqueId].email)) == keccak256(abi.encodePacked(_email)), "Enter Email which is given while creating ID");
        if(emailOTP[_uniqueId] == bytes4(keccak256(abi.encodePacked(_otp)))){
            verifiedEmail[_email] = true;
            rewarduser();
            return true;
            }
    }
    //Verifying user mobieNo using OTP. comapring OTP hash stored in blockchain with OTP user received
    //
    function verifyUserByMobileNo(bytes4 _uniqueId, uint64 _mobileNo, uint _otp) public onlyOwner returns(bool isVerified){
        require(uniqueMobileNo[_mobileNo] = true, "Need another mobileNo" );
        require(users[_uniqueId].mobileNo == _mobileNo, "Enter number which is given while creating ID");

        if(mobileOTP[_uniqueId] == bytes4(keccak256(abi.encodePacked(_otp)))){
            verifiedMobileNo[_mobileNo] = true;
            rewarduser();
            return true;
            }
    }
    // upadting user properties
    function updateUser(bytes4 _uniqueId, string memory _name, string memory _country, string memory _dob) public onlyOwner {
            users[_uniqueId].name = _name;
            users[_uniqueId].country = _country;
            users[_uniqueId].dob = _dob;
            rewarduser();
    }

    //functio to get particular uniqueID info    
    function getIdentity(bytes4 _uniqueId) public view returns (User memory) {
        return users[_uniqueId];
    } 
    //upadting user email info
    function updatEmail(bytes4 _uniqueId, string memory _email) public onlyOwner returns(bool isUpdated){
        users[_uniqueId].email = _email;
        rewarduser();
        return(true);
    }
    //updating user mobileNo info
    function updatPhone(bytes4 _uniqueId, uint64 _mobileNo) public onlyOwner returns(bool isUpdated){
        users[_uniqueId].mobileNo = _mobileNo;
        rewarduser();
        return(true);
    }

    //changing owner
    function changeOwner(address _newOwner) public onlyOwner{
        owner = _newOwner;
    }
    //deleting identity
    function deleteIdentity(bytes4 _uniqueId) public onlyOwner{
        delete users[_uniqueId];

    }
    // function to get all usernames. duplicated data from mapping to array, instantiated dynamic array in function and fetched usernames. 
    function getAllusers() public view onlyOwner returns (string[] memory) {
        string[] memory nameArray = new string[](userArray.length);
        for(uint i = 0; i < userArray.length; i++) {
           bytes4 temp = userArray[i];
            nameArray[i] = users[temp].name;    
        }
        return nameArray;
    }

}