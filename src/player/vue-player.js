import vuePlayer from './vue-player.vue'

const playerPlugin = {}
export default playerPlugin.install = (Vue, options) => {
	Vue.component('vue-player', vuePlayer)
}
