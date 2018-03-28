pragma solidity 0.4.21;

contract LootLotto {
    
    string private constant name = "Loot Lotto";
    string private constant symbol = "LOLO";
    string private constant version = "0.1";
    string private iteration = "March 31 2018 23:59:59 UTC";
    
    address private owner;
    address private winner;  
    
    address[] private founders;
    address[] private executives;
    address[] private team;
    address[] private players;
    address[] private entries;
    
    uint private founderCut = 0;
    uint private executiveCut = 0;
    uint private teamCut = 0;
    uint private playersCut = 0;
    uint private winnersCut = 0;

    uint private winningNumber = 0;
    
    //operational
    uint private numberOfEntries = 0;
    uint private entriesFromAmount = 0;
    
    //4 finney, .04 ether
    uint private constant ticketPrice = 4000000000000000 wei;
    
    //200 finney, .2 ether
    uint private constant maxTicketPurchase = 200000000000000000 wei;
    
    bool private isDrawn = false;
    uint private constant maxTickets = 1000000000;

    uint private startTime;
    uint private endTime;
  
  function getVersion() public pure returns (string) {
    return version;
  }
  
  function getIteration() public view returns (string) {
    return iteration;
    
  }
  
  function getSymbol() public pure returns (string) {
    return symbol;
    
  }
  
  function getName() public pure returns (string) {
    return name;
    
  }
  
  function getEntriesFromAmount() internal constant returns (uint) {
    return entriesFromAmount;
    
  }
  
  function getOwner() public constant returns (address) {
     return owner;
  }
  
  function getWinner() public constant returns (address) {
     return winner;
  }
  
  function getWinnerCut() public constant returns (uint) {
     return winnersCut;
  }
  
   function getFounderCut() public constant returns (uint) {
     return founderCut;
  }
  
  function getExecutiveCut() public constant returns (uint) {
     return executiveCut;
  }
 
  function getTeamCut() public constant returns (uint) {
     return teamCut;
  }
  
  function getPlayersCut() public constant returns (uint) {
     return playersCut;
  }
  
  function getEntryCount() public constant returns (uint) {
     return numberOfEntries;
  }
  
  function getWinningNumber() public constant returns (uint) {
     return winningNumber;
  }
  
  function getCurrentTime() public constant returns (uint) {
    return now;
  }
  
  function getStartTime() public constant returns (uint) {
    return startTime;
  }
  
  function lotteryIsDrawn() public constant returns (bool) {
    return isDrawn;
  }
  
  function getEndTime() public constant returns (uint) {
    return endTime;
  }
  
  function LootLotto(string _iteration, uint _endTime) public {
    owner=msg.sender;
    founders.push(msg.sender);
    executives.push(msg.sender);
    team.push(msg.sender);
    startTime = now;
    endTime = _endTime;
    iteration = _iteration;
  }
  
  function () public payable {
        require(isDrawn==false);
        sellTicket();
  }
  
  function sellTicket() public payable {
    //calculate number of entries based on msg.value
    require(msg.value >= ticketPrice);
    require(msg.value <= maxTicketPurchase);
    entriesFromAmount = (msg.value / ticketPrice);
    require((numberOfEntries + entriesFromAmount) <= maxTickets);
       
    for(uint playEntries = 0; playEntries < entriesFromAmount ; playEntries++){
        numberOfEntries = entries.push(msg.sender);

        winnersCut += (2800 szabo);
        founderCut += (800 szabo);
        executiveCut += (200 szabo);
        teamCut += (120 szabo);
        playersCut += (80 szabo);
    }
    
    players.push(msg.sender);
    
    playEntries = 0;
    entriesFromAmount = 0;
    
    if(endTime < now){
      require(isDrawn==false);
      
      winningNumber = uint(block.blockhash(block.number-1))%numberOfEntries + 1;
      winner = entries[winningNumber];
      
      //the drawing is over, house takes the cut.
      for(uint f=0; f<founders.length; f++){
          founders[f].transfer(founderCut / founders.length);
      }
      
      for(uint e=0;  e<executives.length; e++){
          executives[e].transfer(executiveCut / executives.length);
      }
      
      for(uint t=0; t<team.length; t++){
          team[t].transfer(teamCut / team.length);
      }
      
      
      for(uint p=0; p<players.length; p++){
          players[p].transfer(playersCut / players.length);
      }
      
      winner.transfer(winnersCut);
      isDrawn = true;
    }
  }

  function bytesToAddress(bytes _address) pure internal returns (address) {
    uint160 m = 0;
    uint160 b = 0;

    for (uint8 i = 0; i < 20; i++) {
      m *= 256;
      b = uint160(_address[i]);
      m += (b);
    }

    return address(m);
  }

}
