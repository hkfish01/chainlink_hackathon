import Web3 from 'web3';
export default new class {
  get web3(){
    if(window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      try {
        window.ethereum.enable();
      } catch (error) { console.error( error )}
    } else {
      console.log(
          'Non-Ethereum browser detected. You should consider trying MetaMask!'
      );
    }
    return window.web3
  }
}