import store from "@/x/store"
import web3Util from "@/x/utils/web3"

export default function (to, from, next) {
  if(!to.path.includes("login")) {
    if(to.name === 'buyerDetail' && !web3Util.web3) {
      return next()
    }
    if(to.path.includes("/buyer") && !store.state.buyerToken) {
      return location.href = `/buyer/login?backUrl=${location.href}`
    }
    if(to.path.includes("/seller") && !store.state.sellerToken) {
      return location.href = `/seller/login?backUrl=${location.href}`
    }
  }
  next()
}