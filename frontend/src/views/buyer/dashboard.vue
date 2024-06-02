<template>
  <div class="flex flex-col items-center justify-center min-h-[400px] mt-[100px]"> 
    <el-button @click="actionToMintNft" size="large" type="primary" class="bg-[#409eff] w-[300px]">Mint Nft</el-button>
    <el-button @click="actionToMyNft" size="large" type="primary" class="bg-[#409eff] w-[300px] !ml-0 mt-5">My Nft</el-button>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
const router = useRouter()

function actionToMintNft() {
  router.push({
    name: "buyerNftDetail"
  })
}

function actionToMyNft() {
  router.push({
    name: "buyerNftList"
  })
}
</script>

<style lang='scss' scoped>

</style>