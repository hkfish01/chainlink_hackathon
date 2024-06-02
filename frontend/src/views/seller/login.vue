<template>
  <div class="login">
    <div class="login-body">
      <div class="login-container">
        <div class="login-type-container">
          <div class="login-type">
            <div
              class="login-type-item active"
            >Metamask Login</div>
          </div>
          <div class="w-[100px] m-auto mt-[40px] cursor-pointer" @click="metaMaskLogin">
            <img src="@/assets/images/login/metamask.png" alt="">
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { isMobileBrowser } from "@/x/tools"
// import { ElMessage } from 'element-plus'
import { useStore } from "vuex"
import web3Util from "@/x/utils/web3"
import { useRouter, useRoute } from "vue-router"
const store = useStore()
const router = useRouter()
const route = useRoute()
let chainId = ''
async function actionConnect(){
  if(!web3Util.web3) {
    if(isMobileBrowser()) {
      location.href = `https://metamask.app.link/dapp/${location.href.replace(/http:\/\/|https:\/\//, '')}`
    } else {
      location.href = `https://chromewebstore.google.com/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn`
    }
    return false
  }
  if(chainId !== '0xaa36a7') {
    try {
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: "0xaa36a7" }]
      })
    } catch (error) {
    }
  }
  const web3 = web3Util.web3
  web3.eth.getAccounts().then(async (accounts) => { 
    console.error(accounts)
    if (!accounts[0]) {
      console.error("error account")
      return false;
    }
    const walletAddress = accounts[0]
    console.error(walletAddress)
    store.commit("setSellerToken", walletAddress)
    if(route.query.backUrl) {
      return location.replace(route.query.backUrl)
    }
    router.push({ name: 'sellerCreate' })
  })
}

function metaMaskLogin() {
  actionConnect()
}
</script>

<style lang="scss" scoped>
$login: '.login';
#{$login} {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: auto;
  &-body{
    position: relative;
    flex: 1;
    height: 100%;
    min-height: 300px;
    background-image: url('~@/assets/images/login/login-bg.png');
    background-position: center;
    background-size: cover;
  }
}
#{$login}-container{
  position: absolute;
  top: 50%;
  left: 50%;
  display: flex;
  height: 300px;
  overflow: hidden;
  background: #FFF;
  border-radius:6px;
  transform: translateX(-50%) translateY(-50%);
  padding: 40px;
}

.login-type-container {
  margin-bottom: 92px;
}
.login-type {
  display: flex;
  color: rgba(0, 0, 0, 0.85);
  font-weight: 600;
  font-size: 18px;
  &-item {
    position: relative;
    flex: 1;
    padding-bottom: 6px;
    text-align: center;
    cursor: pointer;
    transition: 0.3s all;
    &::after {
      position: absolute;
      bottom: 0;
      left: 50%;
      display: block;
      width: 0;
      height: 0;
      background: #1890ff;
      border-radius: 3px;
      transform: translateX(-50%);
      transition: 0.3s all;
      content: " ";
    }
    &.active {
      color: #1890ff;
      &::after {
        width: 38px;
        height: 3px;
      }
    }
    &.disabled {
      color: #ccc;
      cursor: not-allowed;
    }
  }
}
</style>