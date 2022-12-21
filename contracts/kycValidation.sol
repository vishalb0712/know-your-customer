// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract KnowYourCustomer {
    address centralBank;

    constructor() {
        centralBank = msg.sender;
    }

    struct bank {
        address ethAddress;
        string bankName;
        uint256 kycCount;
        bool addCustomerPrivilege;
        bool kycPrivilege;
    }

    struct customer {
        string custName;
        string custData;
        address custEthAddress;
        bool customerKycStatus;
    }

    mapping(address => bank) bankDetails;
    mapping(string => customer) customerDetails;

    modifier onlycentralbank() {
        require(
            msg.sender == centralBank,
            "Only central bank can access this function."
        );
        _;
    }

    modifier onlyBank() {
        require(
            bankDetails[msg.sender].ethAddress == msg.sender,
            "Only Bank can access this function."
        );
        _;
    }

    function addBank(
        address _ethAddress,
        string memory _bankName,
        uint256 _kycCount,
        bool _addCustomerPrivilege,
        bool _kycPrivilege
    ) public onlycentralbank {
        bankDetails[_ethAddress].ethAddress = _ethAddress;
        bankDetails[_ethAddress].bankName = _bankName;
        bankDetails[_ethAddress].kycCount = _kycCount;
        bankDetails[_ethAddress].addCustomerPrivilege = _addCustomerPrivilege;
        bankDetails[_ethAddress].kycPrivilege = _kycPrivilege;
    }

    function addCustomer(string memory _custName, string memory _custData)
        public
        onlyBank
    {
        require(
            bankDetails[msg.sender].addCustomerPrivilege,
            "You do not have permission to Add customer"
        );
        customerDetails[_custName].custName = _custName;
        customerDetails[_custName].custData = _custData;
        customerDetails[_custName].custEthAddress = msg.sender;
        customerDetails[_custName].customerKycStatus = false;
    }

    function verifyKYCStatus(string memory _custName)
        public
        view
        returns (bool customerKycStatus)
    {
        return customerDetails[_custName].customerKycStatus;
    }

    function addKYCRequest(string memory _custName, bool _customerKycStatus)
        public
        onlyBank
    {
        require(
            bankDetails[msg.sender].kycPrivilege,
            "You do not have Permission for KYC."
        );
        require(
            customerDetails[_custName].custEthAddress == msg.sender,
            "This customer is not asscociated with you. Can not do KYC update for this customer."
        );
        customerDetails[_custName].customerKycStatus = _customerKycStatus;
        address hereethAddress = customerDetails[_custName].custEthAddress;
        _customerKycStatus == true
            ? bankDetails[hereethAddress].kycCount++
            : bankDetails[hereethAddress].kycCount--;
    }

    function allowBankFromAddingNewCustomers(address _ethAddress)
        public
        onlycentralbank
    {
        bankDetails[_ethAddress].addCustomerPrivilege = true;
    }

    function blockBankFromAddingNewCustomers(address _ethAddress)
        public
        onlycentralbank
    {
        bankDetails[_ethAddress].addCustomerPrivilege = false;
    }

    function allowBankForKyc(address _ethAddress) public onlycentralbank {
        bankDetails[_ethAddress].kycPrivilege = true;
    }

    function blockBankForKyc(address _ethAddress) public onlycentralbank {
        bankDetails[_ethAddress].kycPrivilege = false;
    }

    function viewcustData(string memory _custName)
        public
        view
        returns (
            string memory custName,
            string memory custData,
            address custEthAddress,
            bool customerKycStatus
        )
    {
        return (
            customerDetails[_custName].custName,
            customerDetails[_custName].custData,
            customerDetails[_custName].custEthAddress,
            customerDetails[_custName].customerKycStatus
        );
    }
}
