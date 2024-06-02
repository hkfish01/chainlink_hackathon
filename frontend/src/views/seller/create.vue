<template>
  <div class="min-w-[800px] p-[20px]">
    <div class="bg-white rounded-xl shadow border flex flex-col items-center p-[40px] h-[calc(100vh-100px)] pt-[100px]">
      <div class="font-bold text-[32px]">Upload New Art Work</div>
      <el-form :model="form" label-width="auto">
        <div class="flex border rounded-md mt-[20px] p-[50px]">
          <div class="flex flex-col w-[600px]">
            <el-form-item label="Name:">
              <el-input v-model="form.name" />
            </el-form-item>
            <el-form-item label="Description:">
              <el-input v-model="form.description" type="textarea" rows="8"/>
            </el-form-item>
            <el-form-item label="Base URL:">
              <el-input v-model="form.baseUrl"/>
            </el-form-item>
            <el-form-item label=" ">
              <el-button class="bg-[#409eff]" @click="confirmSave" type="primary">Confirm</el-button>
            </el-form-item>
          </div>
        </div>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { reactive } from "vue";
import apis from "@/x/server"
import { ElMessage } from 'element-plus'

const form = reactive({
  name: '',
  description: '',
  baseUrl: ''
})

async function confirmSave() {
  const { code } = await apis.nft.createCollection({
    ...form,
    contractId: '0x314e34EFfdA6999CF633c737daC961B0907061eF'
  })
  if(code === 200) {
    ElMessage.success('Save Success!')
  }
}

</script>

<style lang='scss' scoped>

</style>