// import Vue from 'vue'
// import App from './App'
// import player from './player/vue-player.js'
//
// Vue.config.productionTip = false
//
// Vue.use(player)
//
// new Vue({
//   el: '#app',
//   template: '<App/>',
//   components: { App }
// })

import player from './player/vue-player.vue'

const playerPlugin = {}
export default playerPlugin.install = (Vue, options) => {
	Vue.component('vue-player', player)
}
