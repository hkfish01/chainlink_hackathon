import { createStore } from 'vuex';
import createPersistedState from 'vuex-persistedstate';

export default createStore({
  plugins: [ createPersistedState({ key: 'local' }) ],
  state: {
    sellerToken: '',
    buyerToken: ''
  },
  mutations: {
    setSellerToken(state, token) {
      state.sellerToken = token;
    },
    setBuyerToken(state, token) {
      state.buyerToken = token;
    }
  },
  getters: {},
  actions: {},
  modules: {}
});