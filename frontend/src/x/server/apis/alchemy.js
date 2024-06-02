import Base from "@/x/server/base"
class Home extends Base {
  queryOwnerNftList(params) {
    return this.get(`https://eth-sepolia.g.alchemy.com/nft/v3/QuTQZh_QuF5O2-rKyxPhsh6gKP1tbIS3/getNFTsForOwner`, params, { headers: {accept: 'application/json'} })
      .then(this._handleResult)
  }

  getNFTMetadata(params){
    return this.get(`https://eth-sepolia.g.alchemy.com/nft/v3/QuTQZh_QuF5O2-rKyxPhsh6gKP1tbIS3/getNFTMetadata`, params, { headers: {accept: 'application/json'} })
      .then(this._handleResult)
  }
}
export default new Home();

// import axios from 'axios';

// const options = {
//   method: 'GET',
//   url: 'https://eth-sepolia.g.alchemy.com/nft/v3/docs-demo/getNFTMetadata',
//   params: {
//     contractAddress: '0xe785E82358879F061BC3dcAC6f0444462D4b5330',
//     tokenId: '44',
//     refreshCache: 'false'
//   },
//   headers: {accept: 'application/json'}
// };

// axios
//   .request(options)
//   .then(function (response) {
//     console.log(response.data);
//   })
//   .catch(function (error) {
//     console.error(error);
//   });