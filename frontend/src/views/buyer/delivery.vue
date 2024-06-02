<template>
  <div class="p-[20px]">
    <div class="bg-white rounded-xl shadow border flex flex-col items-center p-[20px] min-h-[calc(100vh-100px)]">
      <div class="font-bold text-[32px]">Delivery Form</div>
      <div class="flex border rounded-md mt-[20px] p-[20px] flex-wrap flex-col min-w-[50%]">
        <div class="flex flex-col items-center">
          <img class="h-[300px]" :src="nftImage" alt="">
          <span class="text-[24px] mt-[20px]">{{ nftName }}</span>
        </div>
        <div class="flex flex-col mt-[40px]">
          <el-form :model="form" label-width="auto">
            <el-form-item label="Receiver">
              <el-input v-model="form.recipientName" />
            </el-form-item>
            <el-form-item label="Tel:">
              <el-input v-model="form.recipientPhone" />
            </el-form-item>
            <el-form-item label="Address:">
              <el-input v-model="form.recipientAddress" type="textarea" rows="6"/>
            </el-form-item>
            <el-form-item>
              <el-button class="ml-[80px] bg-[#409eff]" type="primary" @click="onSubmit">Submit</el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { useRoute, useRouter} from "vue-router";
import { ElMessage } from 'element-plus'
import { useStore } from "vuex"
import apis from "@/x/server"
const route = useRoute();
const router = useRouter()
const store = useStore();

const form = reactive({
  recipientName: "",
  recipientPhone: "",
  recipientAddress: ""
});

onMounted(() => {
  getNFTMetadata()
})

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

const onSubmit = async () => {
  const { code } = await apis.nft.createNftDetail({
    tokenid: route.query.tokenId,
    userId: store.state.buyerToken,
    name: nftName.value,
    pictures: nftImage.value,
    ...form
  })
  if(code === 200) {
    ElMessage.success("Withdraw Success!")
    setTimeout(() => {
      router.push({
        name: 'buyerNftList'
      })
    }, 2000)
  }
};
</script>
<style lang='scss' scoped>

</style>