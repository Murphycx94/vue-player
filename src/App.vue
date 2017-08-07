<template>
	<div id="app">
		<vue-player :src="src"></vue-player>
	</div>
</template>

<script>

export default {
	name: 'app',
	data() {
		return {
			src: 'https://cdn.theguardian.tv/webM/2015/07/20/150716YesMen_synd_768k_vp8.webm',
		}
	}
}
</script>

<style>
</style>
