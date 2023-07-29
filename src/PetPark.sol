//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
  address private _owner;

  struct Borrower {
    bool borrowed;
    uint256 age;
    Gender gender;
    AnimalType _type;
  }

  mapping(address => Borrower) internal _borrowed;

  mapping(AnimalType => uint256) public animalCounts;

  enum Gender {
    Male,
    Female
  }

  enum AnimalType {
    None,
    Fish,
    Cat,
    Dog,
    Rabbit,
    Parrot
  }

  event Added(AnimalType _type, uint256 _count);
  event Borrowed(AnimalType _type);
  event Returned(AnimalType _type);

  modifier onlyOwner() {
    require(msg.sender == _owner, "Not owner");
    _;
  }

  constructor() {
    _owner = msg.sender;
  }

  function add(AnimalType _type, uint256 _count) external onlyOwner {
    require(_type != AnimalType.None, "Invalid animal");
    animalCounts[_type] += _count;
    emit Added(_type, _count);
  }

  function borrow(uint256 _age, Gender _gender, AnimalType _type) external {
    Borrower memory borrower = _borrowed[msg.sender];
    if (borrower.borrowed) {
      require(borrower.age == _age, "Invalid Age");
      require(borrower.gender == _gender, "Invalid Gender");
    }
    require(_type != AnimalType.None, "Invalid animal type");
    require(animalCounts[_type] > 0, "Selected animal not available");
    require(!_borrowed[msg.sender].borrowed, "Already adopted a pet");
    require(_age > 0, "Need to be older");
    if (_gender == Gender.Male) {
      require(
        (_type == AnimalType.Dog || _type == AnimalType.Fish),
        "Invalid animal for men"
      );
    } else {
      require(
        _age >= 40 || _type != AnimalType.Cat,
        "Invalid animal for women under 40"
      );
    }
    _borrowed[msg.sender] = Borrower(true, _age, _gender, _type);
    animalCounts[_type] -= 1;
    emit Borrowed(_type);
  }

  function giveBackAnimal() external {
    Borrower memory borrower = _borrowed[msg.sender];
    require(borrower.borrowed, "No borrowed pets");
    delete _borrowed[msg.sender];
    animalCounts[borrower._type] += 1;
    emit Returned(borrower._type);
  }
}
