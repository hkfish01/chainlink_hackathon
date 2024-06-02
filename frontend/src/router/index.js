import { createRouter, createWebHistory } from 'vue-router'
import multiguard from 'vue-router-multiguard'
import middlewares from "@/x/middlewares"
import routes from "./routes"
const defaultRoutes = [
  {
    path: '/',
    redirect: '/buyer/dashboard'
  },
  {
    path: '/home',
    name: 'home',
    meta: {
      title: "HOME"
    },
    component: () => import("@/views/home.vue")
  },
  {
    path: '/buyer/dashboard',
    name: 'buyerDashboard',
    meta: {
      title: "Dashboard"
    },
    component: () => import("@/views/buyer/dashboard.vue")
  },
  {
    path: '/buyer/nft/opened',
    name: 'buyerNftOpened',
    meta: {
      title: "NFT List"
    },
    component: () => import("@/views/buyer/opened.vue")
  },
  {
    path: '/buyer/nft/list',
    name: 'buyerNftList',
    meta: {
      title: "NFT List"
    },
    component: () => import("@/views/buyer/nftList.vue")
  },
  {
    path: '/buyer/nft/detail',
    name: 'buyerNftDetail',
    meta: {
      title: "NFT Detail"
    },
    component: () => import("@/views/buyer/nftDetail.vue")
  },
  {
    path: '/buyer/detail',
    name: 'buyerDetail',
    meta: {
      title: "NFT Detail"
    },
    component: () => import("@/views/buyer/detail.vue")
  },
  {
    path: '/seller/create',
    name: 'sellerCreate',
    meta: {
      title: "Create"
    },
    component: () => import("@/views/seller/create.vue")
  },
  {
    path: '/buyer/delivery',
    name: 'buyerDelivery',
    meta: {
      title: "Delivery"
    },
    component: () => import("@/views/buyer/delivery.vue")
  },
  {
    path: '/seller/login',
    name: 'sellerLogin',
    meta: {
      title: "Login"
    },
    component: () => import("@/views/seller/login.vue")
  },
  {
    path: '/buyer/login',
    name: 'buyerLogin',
    meta: {
      title: "Login"
    },
    component: () => import("@/views/buyer/login.vue")
  }
]
const router = createRouter({
  history: createWebHistory(''),
  routes:[...defaultRoutes, ...routes]
})

router.beforeEach(multiguard([...middlewares]))

export default router