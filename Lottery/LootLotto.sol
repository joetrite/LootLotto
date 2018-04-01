pragma solidity 0.4.21;

contract LootLotto {

    address addr;
    uint jackpot;
    uint ticketPrice;
    uint maxTicketsAvailable;
    uint maxEtherAmountPerPlay;
    uint endEpoch;
    uint startEpoch;
    string name;
    string symbol;
    string version;
    string desc;
            
    bool isLocked;
    uint founderCut;
    uint officerCut;
    uint developerCut;
    uint playerCut;
    uint winnerCut;
    
    uint winningNumber ;
    
    uint totalNumberOfTicketsSold;
    
    uint numberOfTicketsForPlay;
    bool isDrawn;
    
    address owner;
    address[] founders;
    address[] officers;    
    address[] developers;    
    address[] players; //this will hold a 
    
    address[] entries;
    address[] winners;
   
    mapping (address => uint) jackpotBalances;
    mapping (address => uint) founderBalances;
    mapping (address => uint) officerBalances;
    mapping (address => uint) developerBalances; 
    mapping (address => uint) playerBalances;
    
    mapping (address => uint) jackpotClaims;
    mapping (address => uint) founderClaims;
    mapping (address => uint) officerClaims;
    mapping (address => uint) developerClaims;
    mapping (address => uint) playerClaims;

      
    function getVersion() public view returns (string) {
        return version;
    }
    
    function getDescription() public view returns (string) {
        return desc;
    }
    
    function getSymbol() public view returns (string) {
        return symbol;
    }
    
    function getName() public view returns (string) {
        return name;
    }
    
    function getNumberOfTicketsForPlay() internal constant returns (uint) {
        return numberOfTicketsForPlay;
    }
    
    function getOwner() public constant returns (address) {
        return owner;
    }
    
    function getWinner(uint idx) public constant returns (address) {
        return winners[idx];
    }
    
    function getWinnerCut() public constant returns (uint) {
     return winnerCut;
    }
    
    function getFounderCut() public constant returns (uint) {
        return founderCut;
    }
    
    function getOfficerCut() public constant returns (uint) {
        return officerCut;
    }
    
    function getDevelopersCut() public constant returns (uint) {
        return developerCut;
    }
    
    function getPlayersCut() public constant returns (uint) {
        return playerCut;
    }
    
    function getEntryCount() public constant returns (uint) {
        return totalNumberOfTicketsSold;
    }
    
    function getWinningNumber() public constant returns (uint) {
        return winningNumber;
    }
    
    function getCurrentTime() public constant returns (uint) {
        return now;
    }
    
    function lotteryIsDrawn() public constant returns (bool) {
        return isDrawn;
    }
    
    function getJackpot() public constant returns (uint) {
        return jackpot;
    }
    
    function getContractBalance() public constant returns (uint) {
        return address(this).balance;
    }
    
    function isFounder(address verify_address) public constant returns (bool) {
        for(uint f=0; f<founders.length; f++){
          if(founders[f] == verify_address) {
              return true;
          }
        }
        return false;
    }
    
    function LootLotto( uint _epochDuration) public {
        owner = msg.sender;
        founders.push(msg.sender);
        officers.push(msg.sender);
        developers.push(msg.sender);
        players.push(msg.sender);
        
        startEpoch = now;
        endEpoch = now + _epochDuration;
        
        name = "Loot Lotto";
        symbol = "LOLO";
        version = "0.1";
        desc = "Etherum based blockchain lottery.";
        
        founderCut = 0;
        officerCut = 0;
        developerCut = 0;
        playerCut = 0;
        winnerCut = 0;
        
        winningNumber = 0;
        
        //operational
        totalNumberOfTicketsSold = 0;
        numberOfTicketsForPlay = 0;
        
        //10 finney, .01 ether
        ticketPrice = 4000000000000000 wei;
        
        //100 finney, .1 ether
        maxEtherAmountPerPlay = 200000000000000000 wei;
        
        isDrawn = false;
        maxTicketsAvailable = 1000000000;
        isLocked = false;
    }
    
    function () public payable {
        require(isDrawn==false);
        require(isLocked==false);
        BuyTicket();
    }
    
    function BuyTicket() public payable {
        require(isDrawn==false);
        require(isLocked==false);
        playerBalances[msg.sender] += msg.value;
        entries.push(msg.sender);
    }
    
    function Draw() public {
        require(isDrawn==false);
        require(isLocked==false);
            
        isLocked=true;
        
        uint contractBalance = getContractBalance();
        jackpot = (contractBalance / 100) * 75;
        founderCut = (contractBalance /100) * 15;
        officerCut = (contractBalance / 100) * 6;
        developerCut = (contractBalance / 100) * 3;
        playerCut = (contractBalance / 100) * 1;
        
        totalNumberOfTicketsSold = (contractBalance / ticketPrice);
        
        //this is not recommended approach to random numbers.  See oraclize.
        winningNumber = uint(block.blockhash(block.number-1))%totalNumberOfTicketsSold + 1;
          
          //fix this
        winners.push(entries[winningNumber]);
        
        endEpoch = now;
        isDrawn = true;
    }
    
    function ClaimJackpot() public payable {
      require(isDrawn);
      winnerCut = 0;
      for(uint w=0; w<winners.length;w++){
          if(winners[w] == msg.sender){
              winners[w].transfer(winnerCut);
          }
      }
    }
    
    function ClaimPlayerShare() public payable {
      require(isDrawn);
      require(playerClaims[msg.sender] == 0);
      playerBalances[msg.sender] = 0;
      msg.sender.transfer(playerCut);
    }
    
    function ClaimFounderShare() public payable {
      require(isDrawn);
      require(founderClaims[msg.sender] == 0);
      founderBalances[msg.sender] = 0;
      msg.sender.transfer(founderCut);
    }
    
    
    function ClaimOfficersShare() public payable {
      require(isDrawn);
      require(officerClaims[msg.sender] == 0);
      officerBalances[msg.sender] = 0;
      msg.sender.transfer(officerCut);
    }
    
    function ClaimDevelopersShare() public payable {
      require(isDrawn);
      require(developerClaims[msg.sender] == 0);
      founderBalances[msg.sender] = 0;
      msg.sender.transfer(playerCut);
    }
    
    
    function DestroyLottery() public payable {
      //after 30 day of a completed lottery, tranfer any unclaimed balances and destroy the contract.
      require(isDrawn);
      require(msg.sender == owner);
    
      if((endEpoch + 2629743) > now) {
        owner.transfer(address(this).balance);
      }
      
      selfdestruct(address(this));
    }
    
    
    function BuyLottery(address _newOwner) public payable {
        require(msg.value > 200 ether);
        owner.transfer(msg.value);
        owner = _newOwner;
    }
}
