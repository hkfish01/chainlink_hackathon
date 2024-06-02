import Base from "@/x/server/base"
class Home extends Base {
  queryNftList() {
    return this.get(`/prod-api/nft/nftProduct/list`, { pageNum: 1, pageSize: 100 }).then(this._handleResult)
  }
  queryNftDetail(id) {
    return this.get(`/prod-api/nft/nftProduct/${id}`).then(this._handleResult)
  }
  createNftDetail(data) {
    return this.post(`/prod-api/nft/nftProduct`, data).then(this._handleResult)
  }

  createCollection(data) {
    return this.post(`/prod-api/nft/collection`, data).then(this._handleResult)
  }
}
export default new Home();