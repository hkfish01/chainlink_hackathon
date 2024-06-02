<template>
  <div class="p-[20px]">
    <div class="bg-white rounded-xl shadow border flex flex-col items-center p-[40px] min-h-[calc(100vh-100px)]">
      <div class="font-bold text-[32px]">NFT NAME</div>
      <div class="border rounded-md flex flex-col items-center mt-[20px] p-[20px]">
        <img class="w-[500px] h-[300px]" :src="nftDetail.image" alt="">
        <span class="text-[24px] mt-[20px]">NFT Name: {{ nftDetail.name }}</span>
        <p>{{ nftDetail.description }}</p>
        <el-button @click="actionMint" type="primary" class="!w-[160px] mt-[20px] bg-[#409eff]" v-if="!hasFinished">Buy</el-button>
        <template v-else>
          <span class="text-[16px] mt-[20px]">Transaction Tx: {{ txId }}</span>
          <div class="flex item-center justify-center">
            <el-button @click="actionBackToList" type="default" class="!w-[160px] mt-[20px] bg-[#409eff]">Back</el-button>
            <el-button @click="actionToDelivery" type="primary" class="!w-[160px] mt-[20px] bg-[#409eff]">Delivery</el-button>
          </div>
        </template>
      </div>
    </div> 
  </div>
</template>

<script setup>
import { isMobileBrowser } from "@/x/tools"
import web3Util from "@/x/utils/web3"
import { ElMessage } from 'element-plus'
// import { ethers } from "ethers"
import { ref } from "vue";
import MintCls from "@/x/utils/mint"
// import BigNumberjs from "bignumber.js";
const MintClsInstance = MintCls.instance
import { ElLoading } from 'element-plus'
import { useRouter } from "vue-router"
const router = useRouter()

const hasFinished = ref(false);

const txId = ref("")
const tokenId = ref("")

const nftDetail = ref({
  description: "Experience the mystical charm of our Drunken Ghosts, where each sip is a step into a fantastical world.",
  image: "https://nftstorage.link/ipfs/bafybeih2yys2zr7gpipkqnzvbwlufjr6pbdju4lkgpj67e367fgilyk5ou",
  name: "OffChainDrunkenAccess"
})
// async function getTokenUri() {
//   // const uri = await MintClsInstance.methods.tokenURI(9).call()
//   // console.log(uri)
//   const linkUrl = `https://nftstorage.link/ipfs/bafybeici3ejk53rujwq5geaywf4eqmqnmpmgfczsupi456aad7idjcs55y/9.json`
//   const res = await fetch(linkUrl)
//   const data = await res.json()
//   nftDetail.value = data
// }


async function actionMint() {
  if(!web3Util.web3) {
    if(isMobileBrowser()) {
      location.href = `https://metamask.app.link/dapp/${location.href.replace(/http:\/\/|https:\/\//, '')}`
    } else {
      location.href = `https://chromewebstore.google.com/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn`
    }
    return false
  }
  const chainId = await window.ethereum.request({ method: 'eth_chainId' })
  console.error(chainId)
  if(chainId !== '0xaa36a7') {
    try {
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: "0xaa36a7" }]
      })
    } catch (error) {
    }
  }
  let loadingInstance1 = null
  try {
    const accounts = await web3Util.web3.eth.getAccounts();
    const account = accounts[0];
    console.error("mint account", account)
    const mintCost = await MintClsInstance.methods.cost().call()
    MintClsInstance.methods.mint(1).send({
      from: account,
      value: mintCost
    }).on("transactionHash", (hash) => {
      txId.value = hash
      loadingInstance1 = ElLoading.service({ fullscreen: true })
    }).on("receipt", async (res) => {
      console.error(res)
      const encodeTokenId = res.logs[0].topics.pop()
      tokenId.value = window.web3.eth.abi.decodeParameter('uint256', encodeTokenId);
      hasFinished.value = true
      loadingInstance1.close()
    }).on("error", (error) => {
      const rejected = "User denied transaction signature.";
      if (error.message && error.message.includes(rejected)) {
        ElMessage.error('We can\'t take your money without your permission.')
        return false;
      }
      if (error) {
        ElMessage.error('There was an issue, please try again.')
        return false;
      }
    });
  } catch (error) {
    console.error(error)
  }
}

function actionBackToList() {
  router.push({ name : 'buyerNftList' })
}

function actionToDelivery() {
  router.push({ name : 'buyerDelivery', query: { tokenId: tokenId.value } })
}

</script>

<style lang='scss' scoped>

</style>