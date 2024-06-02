<template>
  <router-view v-slot="{ Component }">
    <keep-alive>
      <component :is="Component"  v-if="$route.meta.keepAlive"/>
    </keep-alive>
    <component :is="Component"  v-if="!$route.meta.keepAlive"/>
  </router-view>
</template>

<script setup>
</script>

<style lang='scss'>
@import "~@/libs/styles/reset.scss";
@import "~@/libs/styles/common.scss";
@import "~@/libs/styles/base.scss";
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

html {
  @include customScrollbar();
}
</style>
