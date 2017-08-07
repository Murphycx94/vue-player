<template>
	<div class="player" ref="$player">
		<video
			@play="onPlay"
			@loadstart="onLoadstart"
			@canplay="onCanplay"
			@pause="onPause"
			@ended="onEnded"
			@error="onError"
			@timeupdate="onTimeupdate"
			id="video"
			ref="$video"
			:controls="false"
			width="100%"
			height="100%"
			:src="src">
			您的浏览器不支持 video 标签。
		</video>
		<div class="player__mask" @mousemove="showControls" @click.self="changePlayStatus" @dblclick.self="fullScreen">
			<div class="controls" :class="{ 'controls--show': isShowControls || !playStatus }">
				<!-- 控件 -->
				<div class="controls-box">
					<div class="controls-item">
						<div class="controls-item__button" @click="changePlayStatus">
							<i class="iconfont" :class="{ 'icon-video-play': !playStatus, 'icon-video-pause': playStatus }"></i>
						</div>
					</div>
					<!-- 播放时长 -->
					<div class="controls-item">{{ currentTime | secondsFormat }} / {{ totalTime | secondsFormat }}</div>
				</div>
				<div class="controls-box">
					<div class="controls-item">
						<div class="controls-item__button" @click="valumeMute">
							<i class="iconfont" :class="{ 'icon-video-volume': !isMute, 'icon-video-mute': isMute }"></i>
						</div>
						<div class="controls-item__progress" ref="$volumeProgress" @click="valumeSelect($event)">
							<div class="progress__bar"></div>
							<div class="progress__play" :style="{ width: volume + '%' }">
								<div class="progress__circle" @mousedown.prevent="volumeDown"></div>
							</div>
						</div>
					</div>
					<div class="controls-item">
						<div class="controls-item__button" @click="fullScreen">
							<i class="iconfont icon-video-fullscreen"></i>
						</div>
					</div>
				</div>
				<!-- 进度条 -->
				<div class="player__progress" @click="onSelect($event)" ref="$progress">
					<div class="progress__bar"></div>
					<div class="progress__load" :style="{ width: loadPercent + '%' }"></div>
					<div class="progress__play" :style="{ width: percent + '%' }">
						<div class="progress__circle" @mousedown.prevent="onButtonDown">
						</div>
					</div>
				</div>
			</div>
		</div>
		<img v-if="src !==null && !playStatus" class="player__logo" @click.self="changePlayStatus" src="./play.png" alt="点击播放">
		<div v-if="src === null || err " class="player__err">
			<slot name="err">
				<p class="err">播放源出问题啦  (╯￣Д￣)╯╘═╛</p>
			</slot>
		</div>
	</div>
</template>

<script>
	export default {
		props: {
			src: {
				type: String,
				default: null,
			},
		},
		data () {
			return {
				playStatus: false,         // 播放状态
				totalTime: 0,              // video总时长
				currentTime: 0,            // 已播放时长
				loadTime: 0,               // 已缓冲时长
				canPlay: false,            // 是否可以播放
				lineWidth: 0,              // 已播放长度
				isDragging: false,         // 是否正在拖放
				volume: 100,               // 音量
				volumeTem: 100,            // 暂存音量
				isVolumeDrgging: false,	   // 是否正在拖放音量
				isShowControls: false,     // 是否显示控制条
				timer: null,
				err: false,
			}
		},
		mounted () {
			this.$nextTick(() => {
				this.volume = this.$refs.$video.volume * 100
			})
		},
		methods: {
//---------------------------------进度条拖动start--------------------------------
			onButtonDown (event) {
				this.isDragging = true
				this.onDragStart(event)
				window.addEventListener('mousemove',   this.onDragging)
				window.addEventListener('mouseup',     this.onDragEnd)
				window.addEventListener('contextmenu', this.onDragEnd)
			},
			onDragStart (event) {
				// console.log('start',event.clientX)
			},
			onDragging (event) {
				if (this.isDragging) {
					let val = event.clientX - this.$refs.$progress.getBoundingClientRect().left
					val = val < 0 ? 0 : val
					val = val > this.$refs.$progress.offsetWidth ? this.$refs.$progress.offsetWidth : val
					this.lineWidth = val
				}
			},
			onDragEnd () {
				if (this.isDragging) {
					//	防止在 mouseup 后立即触发onSelect的click，导致滑块有几率产生一小段位移
					//	这个坑，element源码是这样解决的
					setTimeout(() => {
						this.isDragging = false
					}, 0)
					window.removeEventListener('mousemove',   this.onDragging)
					window.removeEventListener('mouseup',     this.onDragEnd)
					window.removeEventListener('contextmenu', this.onDragEnd)
				}
			},
//---------------------------------进度条拖动end---------------------------------
//---------------------------------音量条拖动start-------------------------------
			volumeDown () {
				this.isVolumeDrgging = true
				this.valumeDragStart(event)
				window.addEventListener('mousemove',   this.valumeDragging)
				window.addEventListener('mouseup',     this.valumeDragEnd)
				window.addEventListener('contextmenu', this.valumeDragEnd)
			},
			valumeDragStart (event) {
				// TODO
			},
			valumeDragging (event) {
				if (this.isVolumeDrgging) {
					let val = event.clientX - this.$refs.$volumeProgress.getBoundingClientRect().left
					val = val < 0 ? 0 : val
					val = val > this.$refs.$volumeProgress.offsetWidth ? this.$refs.$volumeProgress.offsetWidth : val
					this.volume = val
				}
			},
			valumeDragEnd () {
				if (this.isVolumeDrgging) {
					//	防止在 mouseup 后立即触发onSelect的click，导致滑块有几率产生一小段位移
					//	这个坑，element源码是这样解决的
					setTimeout(() => {
						this.isVolumeDrgging = false
					}, 0)
					window.removeEventListener('mousemove',   this.valumeDragging)
					window.removeEventListener('mouseup',     this.valumeDragEnd)
					window.removeEventListener('contextmenu', this.valumeDragEnd)
				}
			},
//---------------------------------音量条拖动end---------------------------------
//---------------------------------video控制方法start----------------------------
			changePlayStatus () {
				this.playStatus = !this.playStatus
			},
			onSelect (event) {
				if (this.isDragging) return
				this.lineWidth = event.offsetX
			},
			valumeSelect (event) {
				if (this.isVolumeDrgging) return
				this.volume = event.offsetX
			},
			valumeMute () {
				if (!this.isMute) {
					this.volumeTem = this.volume
					this.volume = 0
				} else {
					this.volume = this.volumeTem
				}
			},
			fullScreen () {
				const fullscreenElement =
					document.fullscreenElement ||
					document.mozFullScreenElement ||
					document.webkitFullscreenElement
				if (fullscreenElement) {
					try {
						['exitFullscreen', 'msExitFullscreen', 'mozCancelFullScreen', 'webkitExitFullscreen'].forEach(v => {
							if (v in document) {
								document[v]()
								throw v
							}
						})
					} catch(e) {
						// console.log(e)
					}
				} else {
					try {
						['requestFullscreen', 'mozRequestFullscreen', 'webkitRequestFullscreen'].forEach(v => {
							if (v in this.$refs.$player) {
								this.$refs.$player[v]()
								throw v
							}
						})
					} catch(e) {
						// console.log(e)
					}
				}
			},
			showControls () {
				if (this.timer) {
					clearTimeout(this.timer)
					delete this.timer
				}
				this.isShowControls = true
				this.timer = setTimeout(() => {
					this.isShowControls = false
				}, 2000)
			},
//---------------------------------video控制方法end-----------------------------
//---------------------------------video事件绑定start----------------------------
			onLoadstart () {
				this.canPlay = false
			},
			onCanplay () {
				this.canPlay = true
				this.totalTime   = this.$refs.$video.duration
				this.currentTime = this.$refs.$video.currentTime
			},
			onPause () {
				this.playStatus  = false
			},
			onPlay () {
				this.playStatus  = true
			},
			onEnded () {
				this.playStatus  = false
				this.currentTime = 0
				this.$refs.$video.currentTime = 0
			},
			onError (e) {
				//TODO
			},
			onTimeupdate () {
				if (!this.isDragging && this.$refs.$video.buffered.length > 0) {
					this.currentTime = this.$refs.$video.currentTime
					this.loadTime = this.$refs.$video.buffered.end(0)
				}
			},
//---------------------------------video事件绑定end-------------------------------
//---------------------------------暴露控制方法start-------------------------------
			play (src) {
				if (src != this.src) {
					this.totalTime = 0
					this.currentTime = 0
					this.loadTime = 0
					this.src = src
				} else {
					return this.$refs.$video.play()
				}
			},
			pause () {
				this.$refs.$video.pause()
			},
			setVolume (value) {
				this.volume = value
			},
//---------------------------------暴露控制方法end-------------------------------
		},
		computed: {
			percent () {
				return this.currentTime / this.totalTime * 100
			},
			loadPercent () {
				return	this.loadTime / this.totalTime * 100
			},
			isMute () {
				return !this.volume
			},
		},
		watch: {
			playStatus (status) {
				if (status) {
					this.$refs.$video.play()
				} else {
					this.$refs.$video.pause()
				}
			},
			volume (val) {
				this.$refs.$video.volume = this.volume / 100
			},
			lineWidth (val) {
				let percent = val / this.$refs.$video.offsetWidth * this.totalTime
				this.currentTime = percent
				this.$refs.$video.currentTime = percent
			},
			// canPlay (val) {
			// 	if (val) {
			// 		this.$refs.$video.play()
			// 	}
			// }
		},
		filters: {
			secondsFormat (time) {
				time = time || 0
				let [h, m, s] = [
					parseInt(time / 3600),
					parseInt(time % 3600 / 60),
					parseInt(time % 60)
				]
				h = h < 10 ? '0' + h : h
				m = m < 10 ? '0' + m : m
				s = s < 10 ? '0' + s : s
				return `${h}:${m}:${s}`
			}
		}
	}
</script>

<style scoped lang="less">
	@import "//at.alicdn.com/t/font_ckl7nljllpst6gvi.css";
	.player {
		position: relative;
		background-color: #000;
		overflow: hidden;
		width: 720px;
		height: 480px;
		color: #aaa;
		-moz-user-select: none;
		-webkit-user-select: none;
		-ms-user-select: none;
		-khtml-user-select: none;
		user-select: none;
		&:-webkit-full-screen {
			position: fixed!important;
			top: 0;
			right: 0;
			bottom: 0;
			left: 0;
			margin: 0;
			width: 100%!important;
			height: 100%!important;
			box-sizing: border-box;
			object-fit: contain;
			background-color: #000;
		}
		.player__mask {
			position: absolute;
			left: 0;
			right: 0;
			top: 0;
			bottom: 0;
			background: transparent;
			z-index: 1;
			.controls {
				display: flex;
				position: absolute;
				justify-content: space-between;
				left: 0;
				bottom: -40px;
				padding: 0 15px;
				width: 100%;
				height: 40px;
				line-height: 40px;
				z-index: 5;
				background: rgba(26,26,26,.8);
				transition: all .2s ease-in-out;
				&.controls--show {
					bottom: 0;
				}
				&:hover {
					bottom: 0;
				}
				.controls-box {
					display: flex;
					.controls-item {
						display: flex;
						margin: 0 10px;
						font-weight: 300;
						.controls-item__button {
							cursor: pointer;
							transition: all .2s ease-in;
							&:hover {
								color: #31bedb;
							}
							i {
								font-size: 18px;
							}
						}
						.controls-item__progress {
							position: relative;
							width: 100px;
							height: 20px;
							margin: 10px 15px;
							cursor: pointer;
							.progress__bar {
								position: absolute;
								left: 0;
								top: 50%;
								margin-top: -1px;
								width: 100px;
								height: 2px;
								background: #666;
							}
							.progress__play {
								position: absolute;
								left: 0;
								top: 50%;
								margin-top: -1px;
								height: 2px;
								background: #31bedb;
								.progress__circle {
									background-color: #31bedb;
									height: 10px;
									width: 10px;
									border-radius: 50%;
									position: absolute;
									right: -5px;
									top: -4px;
									z-index: 5;
								}
							}
						}
					}
				}
				.player__progress {
					position: absolute;
					cursor: pointer;
					top: -15px;
					left: 0;
					height: 15px;
					width: 100%;
					background-color: transparent;
					.progress__bar,
					.progress__load,
					.progress__play {
						position: absolute;
						bottom: 0;
						left: 0;
						height: 2px;
						transition: height .2s linear;
					}
					.progress__bar {
						width: 100%;
						background-color: rgba(0,0,0,.5);
						z-index: 10;
					}
					.progress__load {
						z-index: 20;
						background: #828282;
						opacity: 0.6;
					}
					.progress__play {
						background: #31bedb;
						z-index: 30;
						.progress__circle {
							position: absolute;
							background-color: #fff;
							border-radius: 50%;
							cursor: pointer;
							height: 0;
							width: 0;
							opacity: 0;
							top: 0;
							right: 0;
							box-shadow: -1px 0 5px #626262;
							transition: all .2s linear;
							z-index: 40;
						}
					}
					&:hover {
						.progress__bar,
						.progress__load,
						.progress__play {
							height: 15px;
						}
						.progress__circle {
							margin-right: -8px;
							height: 16px;
							width: 16px;
							opacity: 1;
						}
					}
				}
			}
		}
		.player__logo {
			position: absolute;
			left: 0;
			right: 0;
			top: 0;
			bottom: 0;
			margin: auto;
			height: 96px;
			width: 96px;
			cursor: pointer;
			background-color: transparent;
			z-index: 2;
		}
		.player__err {
			position: absolute;
			left: 0;
			right: 0;
			top: 0;
			bottom: 0;
			z-index: 3;
			cursor: default;
			.err {
				position: absolute;
				left: 0;
				right: 0;
				top: 0;
				bottom: 0;
				margin: auto;
				width: 100%;
				height: 20px;
				line-height: 20px;
				text-align: center;
			}
		}
	}
	/* #video::-webkit-media-controls-enclosure {
		禁用播放器控制栏的样式
		display: none !important;
	}


	@font-face {
		font-family: "iconfont";
		src: url('./font_ckl7nljllpst6gvi.eot?t=1501837971807'), IE9
		url('./font_ckl7nljllpst6gvi.woff?t=1501837971807') format('woff'), chrome, firefox
		url('./font_ckl7nljllpst6gvi.ttf?t=1501837971807') format('truetype'), chrome, firefox, opera, Safari, Android, iOS 4.2+
		url('./font_ckl7nljllpst6gvi.svg?t=1501837971807#iconfont') format('svg'); iOS 4.1-
	}

	.iconfont {
		font-family:"iconfont" !important;
		font-size:16px;
		font-style:normal;
		-webkit-font-smoothing: antialiased;
		-moz-osx-font-smoothing: grayscale;
	}

	.icon-video-play:before { content: "e62f"; }

	.icon-video-next:before { content: "e630"; }

	.icon-video-mute:before { content: "e631"; }

	.icon-video-pause:before { content: "e632"; }

	.icon-video-volume:before { content: "e634"; } */
</style>
