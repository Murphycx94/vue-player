[![Version](http://img.shields.io/npm/v/vue-player.svg)](https://www.npmjs.com/package/vue-player)[![Downloads](http://img.shields.io/npm/dm/vue-player-plugin.svg)](https://www.npmjs.com/package/vue-player-plugin)[![License](https://img.shields.io/npm/l/vue-player.svg?style=flat)](https://opensource.org/licenses/MIT)

# vue-player
> A Vue2 H5 video player 基于vue2的H5播放器  
我在项目开发中需要一个Vue的H5播放器，但是没有Vue播放器让我满意，所以我决定自己封装一个H5的播放器。  
我希望它功能简单，接近原生播放器，样式是我喜欢的样子。  

## Getting Start
---
###Installation

``` bash
npm install vue-player -S
```

###Usage

**register VuePlayer globally**
``` javascript
import Vue from 'vue'
import VuePlayer from 'vue-player'
import 'vue-player/vue-player.min.css'

Vue.use(VuePlayer)
```
``` html
<template>
	<div>
		<vue-player :src="src"></vue-player>
	</div>
</template>

<script>

export default {
	data() {
		return {
			src: url
		}
	}
}
</script>
```

###simple exmple

``` html
<template>
	<div>
		<vue-player :src="src" ref="player"></vue-player>
	</div>
</template>

<script>

export default {
	data() {
		return {
			src: url
			newSrc: newUrl
		}
	},
	methods: {
		/**
		 * play video or play new video
		 * @method playVdieo
		 */
		playVdieo() {
			this.$refs.player.play(this.newSrc)
			/* or this.$refs.player.play() */
		},
		/**
		 * pauseVdieo
		 * @method pauseVdieo
		 */
		pauseVdieo() {
			this.$refs.player.pause()
		},
	}
}
</script>
```

**Error notification**
``` html
<template>
	<div>
		<vue-player :src="src">
			<h1 slot="err"> Video resource error </h1>  <!-- src = null or error -->
		</vue-player>
	</div>
</template>
```
