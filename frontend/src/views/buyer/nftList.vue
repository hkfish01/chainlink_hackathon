<template>
<div class="p-[20px]">
  <el-tabs v-model="activeName">
    <el-tab-pane label="MY NFT(Sealed)" name="first">
      <!-- <el-button @click="mintNewNft" type="primary" class="mb-[10px] bg-[#409eff]">Mint New</el-button> -->
      <div class="">
        <div class="bg-white rounded-xl pr-[10px] pb-[10px] flex flex-wrap gap-[20px] min-h-[400px]" v-loading="!mintedLoadingDone"> 
          <template v-if="mintedNftList.length">
            <div v-for="item in mintedNftList" :key="item" class="flex flex-col border min-w-[240px] max-w-[100%] shadow rounded-xl flex-1 overflow-hidden p-[15px]">
              <img :src="item.raw.metadata.image" class="w-full h-[200px]" alt="">
              <div class="text-[16px] font-bold mt-4">NFT Name: {{ item.raw.metadata.name }}</div>
              <el-button v-if="!hasWithdrawedIds.includes(item.tokenId)" @click="nftWithdraw(item.tokenId)" type="primary" class="bg-[#409eff] !w-[100px] m-auto mt-4">Withdraw</el-button>
              <el-button v-else class="!w-[100px] m-auto mt-4" disabled>Delivered</el-button>
            </div>
            <div v-for="item in 5" :key="item" class="flex min-w-[240px] max-w-[100%] h-[0px] flex-1 px-[15px]">
            </div>
          </template>
          <div class="min-h-[300px] w-full flex items-center justify-center" v-if="mintedLoadingDone && mintedNftList.length === 0">
            <el-empty description="No NFT"></el-empty>
          </div>
        </div>
      </div>
    </el-tab-pane>
    <el-tab-pane label="MY NFT(Opened)" name="second">
      <div class="">
        <div class="bg-white rounded-xl p-[10px] flex flex-wrap gap-[20px]" v-loading="!openedLoadingDone">
          <template v-if="openedNftList.length">
            <div v-for="item in openedNftList" :key="item" class="flex flex-col border min-w-[240px] shadow rounded-xl flex-1 overflow-hidden p-[20px]">
              <img :src="item.raw.metadata.image" class="w-full h-[200px]" alt="">
              <div class="text-[16px] font-bold mt-4">NFT Name: {{ item.raw.metadata.name }}</div>
            </div>
            <div v-for="item in 5" :key="item" class="flex min-w-[240px] max-w-[100%] h-[0px] flex-1  px-[15px]">
            </div>
          </template>
          <div class="min-h-[300px] w-full flex items-center justify-center" v-if="openedLoadingDone && openedNftList.length === 0">
            <el-empty description="No NFT"></el-empty>
          </div>
        </div>
      </div>
    </el-tab-pane>
  </el-tabs>
</div>
</template>

<script setup>
import { onMounted, ref } from "vue";
import apis from "@/x/server";
import { useRouter } from "vue-router"
import { useStore } from "vuex"
const router = useRouter()
const store = useStore()

const activeName = ref("first")
// function mintNewNft() {
//   router.push({
//     name: 'buyerNftDetail'
//   })
// }

onMounted(() => {
  getMintedNftList()
  getOpenedNftList()
  getWithdrawList()
})

const mintedNftList = ref([])
const mintedLoadingDone = ref(false)
async function getMintedNftList() {
  const { ownedNfts } = await apis.alchemy.queryOwnerNftList({
    owner: store.state.buyerToken,
    'contractAddresses[]': '0x314e34EFfdA6999CF633c737daC961B0907061eF',
    withMetadata: 'true',
    pageSize: '100'
  })
  mintedNftList.value = ownedNfts
  mintedLoadingDone.value = true
}

const openedNftList = ref([])
const openedLoadingDone = ref(false)
async function getOpenedNftList() {
  const { ownedNfts } = await apis.alchemy.queryOwnerNftList({
    owner: store.state.buyerToken,
    'contractAddresses[]': '0x589469Ac6bA85c441c91DcA4A4A1a88BAe556aBE',
    withMetadata: 'true',
    pageSize: '100'
  })
  openedNftList.value = ownedNfts
  openedLoadingDone.value = true
}


function nftWithdraw(tokenId) {
  router.push({
    name: 'buyerDelivery',
    query: {
      tokenId
    }
  })
}

const hasWithdrawedIds = ref([])
async function getWithdrawList() {
  const { code, rows } = await apis.nft.queryNftList()
  if(code === 200) {
    hasWithdrawedIds.value = rows.map((row) => row.tokenid)
  }
}
</script>

<style lang='scss' scoped>

</style>