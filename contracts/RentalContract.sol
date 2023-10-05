// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract RentalContract {

    enum PropertyType {HOME,SHOP}

    struct Rental{
        uint256 rentalId;
        address owner;
        string rentalAddress;
        PropertyType propertyType;
        
    }

    struct ContractInformation {
        Rental base;
        address tenantAddress;
        uint256 startYear;
        uint256 endYear;
        bool isActive;
    }

    mapping (address => ContractInformation[]) contractInfos;
    mapping (address => Rental[]) owners;

    modifier onlyOwner(){
        require(owners[msg.sender].length > 0,"Sadece Mekan sahibi kullanabilir");
        _;
    }

    function AddOwner(uint256 _rentalId,string memory _rentalAddress,string memory _propertyType) public {
        PropertyType ptype;
        if((keccak256(abi.encodePacked(_propertyType)) == keccak256(abi.encodePacked("home")))){
            ptype = PropertyType.HOME;
        }else if((keccak256(abi.encodePacked(_propertyType)) == keccak256(abi.encodePacked("shop")))){
            ptype = PropertyType.SHOP;
        }else{
            revert("Property tipini home veya shop olarak giriniz.");
        }
        for (uint256 i = 0; i < owners[msg.sender].length; i++) {
            if (owners[msg.sender][i].rentalId == _rentalId) {
                revert(unicode"Rental Id kullanılıyor");
            }
        }
            
        Rental memory newOwner = Rental({
            rentalId: _rentalId,
            owner: msg.sender,
            rentalAddress: _rentalAddress,
            propertyType: ptype
        });
        owners[msg.sender].push(newOwner);
    }

    function ownerRentalCount() onlyOwner public view returns (uint256) {
        return owners[msg.sender].length;
    }

    
    function createRentalContract(
        address _tenantAddress,
        uint256 _rentalId,
        uint256 _startYear,
        uint256 _endYear
        ) public onlyOwner {
            Rental memory rental;
            for (uint256 i = 0; i < owners[msg.sender].length; i++) {
                if (owners[msg.sender][i].rentalId == _rentalId) {
                    rental = owners[msg.sender][i];
                    break;
                }
            }
            require(rental.rentalId == _rentalId,unicode"Kiralık yer bulunamadı");

            ContractInformation memory newContract = ContractInformation({
                base: rental,
                tenantAddress: _tenantAddress,
                startYear: _startYear,
                endYear: _endYear,
                isActive: true
            });

            contractInfos[msg.sender].push(newContract);
        }

    function getRentalContract(uint256 _rentalId) public view returns(
        uint256 rentalId,
        address owner,
        string memory rentalAddress,
        PropertyType propertyType,
        address tenantAddress,
        uint256 startYear,
        uint256 endYear,
        bool isActive) {

    Rental memory rental;
    for (uint256 i = 0; i < owners[msg.sender].length; i++) {
        if (owners[msg.sender][i].rentalId == _rentalId) {
            rental = owners[msg.sender][i];
            break;
        }
    }
    require(rental.rentalId == _rentalId,unicode"Rental Id geçerli değil");

    ContractInformation memory contractInfo;
    for (uint256 i = 0; i < contractInfos[msg.sender].length; i++) {
        if (contractInfos[msg.sender][i].base.rentalId == rental.rentalId) {
            contractInfo = contractInfos[msg.sender][i];
            break;
        }
    }
    require(contractInfo.tenantAddress != address(0),unicode"Sözleşme bulunamadı");

    return (
        rental.rentalId,
        rental.owner,
        rental.rentalAddress,
        rental.propertyType,
        contractInfo.tenantAddress,
        contractInfo.startYear,
        contractInfo.endYear,
        contractInfo.isActive
    );
    }

    function cancelContract(uint256 _rentalId) public onlyOwner{
        ContractInformation memory contractInfo;
        for (uint256 i = 0; i < contractInfos[msg.sender].length; i++) {
            if (contractInfos[msg.sender][i].base.rentalId == _rentalId) {
                contractInfo = contractInfos[msg.sender][i];
                delete contractInfos[msg.sender][i];
                break;
            }
        }
        require(contractInfo.base.rentalId == _rentalId,unicode"Rental Id geçerli değil");
        
    }

    function ownerRentals() public view returns(Rental[] memory){
        return owners[msg.sender];
    }

}