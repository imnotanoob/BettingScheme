pragma solidity ^0.4.8;

contract BettingScheme {
    address public creator;
    uint public createdAtTime;

        struct Bet {
        //Person 1 Bet Amount in Wei
        uint person1Bet;
        //Person 2 Bet Amount
        uint person2Bet;
        //Total bet
        uint totalBet;
        address person1Address;
        address person2Address;
    }
    //Mapping of Bet ID to BetAmount. 
    mapping(uint256 => Bet) bets;



    event LogBetDetails(uint person1Bet, uint person2Bet, uint totalBet, address person1Address, address person2Address);

    function BettingScheme() public {
        creator = msg.sender;
        createdAtTime = now;
    }

    modifier isCreator() {
        if (msg.sender != creator) return;
        _;
    }

    //I need one function that allows Better 1 and Better 2 to send funds for a bet id.
    function depositBet(uint256 betID) public payable returns (bool) {
        Bet storage bet = bets[betID];
        uint amount = msg.value;
        if (bet.person1Bet == 0) {
            bets[betID].person1Bet = amount;
            bets[betID].person1Address = msg.sender;
            bets[betID].totalBet += amount;
        } else if (bet.person2Bet == 0) {
            bets[betID].person2Bet = amount;
            bets[betID].totalBet += amount;
            bets[betID].person2Address = msg.sender;
        } else { // Need this else in case they try to deposit bet twice.
            return false;
        }
        if (!creator.send(amount)) {
            return false;
        }
        return true;

    }

    function getBetDetails(uint betID) public {
        Bet storage bet = bets[betID];
        emit LogBetDetails(bet.person1Bet, bet.person2Bet, bet.totalBet, bet.person1Address, bet.person2Address);
    }

    function removeContract()
        public
        isCreator()
        {
            selfdestruct(msg.sender);
            // creator gets all money that hasn't be claimed
        }
}