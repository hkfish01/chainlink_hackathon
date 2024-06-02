<template>
  <div class="flex flex-col items-center p-[20px] pt-[20px]">
    <div class="w-full max-w-[400px] bg-[#eee]">
      <img class="w-full h-auto" :src="nftImage" alt="">
    </div>
    <div class="font-bold text-[18px] mt-2">Name: {{ nftName }}</div>
    <div class="text-[18px] mt-2" v-if="currentCost">Current Price: {{ currentCost }}ETH</div>
    <el-button v-if="isOpen" disabled class="mt-6 w-[fit-content] m-auto !px-[40px]">Has Opened !</el-button>
    <template v-else>
      <el-button v-if="hasFinished" @click="actionDone" type="primary" class="bg-[#409eff] mt-6 w-[fit-content] m-auto !px-[40px]">Done</el-button>
      <el-button v-else @click="actionOpen" type="primary" class="bg-[#409eff] mt-6 w-[fit-content] m-auto !px-[40px]">Open it</el-button>
    </template>
  </div>
</template>

<script setup>
import web3Util from "@/x/utils/web3"
import MintCls from "@/x/utils/mint"
import { useRoute, useRouter } from 'vue-router'
import { computed, onBeforeMount, ref } from "vue"
const route = useRoute()
const router = useRouter()
import { ElLoading, ElMessage } from 'element-plus'
import apis from "@/x/server"

const isOpen = computed(() => {
  // 字符串倒数第7位 x: 未开 y: 已开
  // const regex=/.{14}(.){6}/;
  // const str = location.href;
  // console.error("str", str)
  // const match = str.match(regex);
  // if(match){
  //   const middleChar = match[1];
  //   console.error(middleChar)
  //   return middleChar === 'y'
  // } else { console.log("No match found"); }
  // return true
  const str = location.href
  console.error(str.substr(-7, 1))
  return str.substr(-7, 1) === 'y'
})

onBeforeMount(() => {
  getNFTMetadata()
  getCurrentCost()
})

const MintClsInstance = MintCls.instance
const txId = ref("")
const hasFinished = ref(false)
async function actionOpen() {
  if(!web3Util.web3) {
    location.href = `https://metamask.app.link/dapp/${location.href.replace(/http:\/\/|https:\/\//, '')}`
    return
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
    const tokenId = route.query.tokenId
    MintClsInstance.methods.open(Number(tokenId)).send({
      from: account
    }).on("transactionHash", (hash) => {
      txId.value = hash
      loadingInstance1 = ElLoading.service({ fullscreen: true })
    }).on("receipt", async () => {
      // // 调用update接口
      hasFinished.value = true
      loadingInstance1.close()
      // router.push({ name: 'buyerNftOpened',query: { txId: txId.value } })
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

function actionDone() {
  router.replace({ name: 'buyerNftList' })
}
const nftImage = ref("")
const nftName = ref("")
async function getNFTMetadata() {
  const metadata = await apis.alchemy.getNFTMetadata({
    tokenId: route.query.tokenId,
    contractAddress: '0x314e34EFfdA6999CF633c737daC961B0907061eF',
    refreshCache: 'false'
  })
  nftImage.value = metadata.raw.metadata.image
  nftName.value = metadata.raw.metadata.name
}

const currentCost = ref(0)
async function getCurrentCost() {
  if(!web3Util.web3) {
    // ElMessage.error("Please connect Metamask first");
    return 
  }
  const mintCost = await MintClsInstance.methods.cost().call()
  const perTokenCost =  web3Util.web3.utils.fromWei(mintCost, 'ether')
  currentCost.value = perTokenCost
}

</script>

<style lang='scss' scoped></style>