<script>
import {onMounted, reactive, ref, watch, watchEffect} from 'vue'
import axios from "axios"

export default {
    setup(){ 
        const musicData = reactive({});
        const currentSong = reactive({});
        const playing = ref(false);
        const songNum = ref(1);
        const musicDuration = ref(null);
        const musicCurrentTime = ref(null);
        const processPercentage = ref(null);

        watch(
            musicCurrentTime,
            (curtime)=>{
                let musicDuration = document.querySelector('#musicPlayer');
                timeFormat(musicDuration.duration) 
        })
        
        watchEffect(
            ()=>{
                if(musicCurrentTime.value != null){
                    if(musicCurrentTime.value === musicDuration.value){
                        nextSong();
                    }
                }
        })

        setInterval(()=>{
            if(playing.value === true){
                let curTime = document.querySelector('#musicPlayer').currentTime;
                let totalTime = document.querySelector('#musicPlayer').duration;
                let min = Math.floor(curTime/60) % 60 ;
                let sec = Math.floor(curTime) % 60 ;
                if(sec < 10 ){
                    sec = "0" + sec ;
                }
                musicCurrentTime.value = ("0" + min + ":" + sec );
                processPercentage.value = (100/totalTime) * curTime;
            }
        },1000)

        const timeFormat = (time,percent)=>{
            if(percent != undefined){
                let musicPlayer = document.querySelector('#musicPlayer');
                let min = Math.floor(((time / 100) * percent) / 60 ) % 60 ;
                let sec = Math.floor( (time / 100) * percent) % 60 ;
                if(sec < 10 ){
                    sec = "0" + sec ;
                }
                musicCurrentTime.value = ("0" + min + ":" + sec );
                let markTime = ((time / 100) * percent);
                musicPlayer.currentTime = markTime ;
                playAndPause();
            }else{
                let min = Math.floor(time/60) % 60 ;
                let sec = Math.floor(time) % 60 ;
                if(sec < 10 ){
                    sec = "0" + sec ;
                }
                musicDuration.value = ("0" + min + ":" + sec ); 
            }
        }

        const updateProcessBar = (x)=>{
            let processBar = document.querySelector(".processBar");
            let totalTime = document.querySelector('#musicPlayer').duration;
            let position = x - processBar.offsetLeft;
            let percentage = (100 * position) / processBar.offsetWidth;
            processPercentage.value = percentage;
            timeFormat(totalTime,percentage);
        }

        const processPosition = (e)=>{
            playAndPause();
            updateProcessBar(e.pageX);
        }
        
        const playAndPause = ()=>{
            playing.value = !playing.value;
            let musicStatus = document.querySelector('#musicPlayer');
            if(playing.value === true){
                musicStatus.play();
            }else if(playing.value === false){
                musicStatus.pause();
            }
        }

        const nextSong = ()=>{
            songNum.value += 1 ; 
            musicCurrentTime.value = null ;
            processPercentage.value = null ;
            if(songNum.value > 10){
                songNum.value = 1 ;
            }
            currentSong.url = musicData.src["data"+ songNum.value].url;
            currentSong.song = musicData.src["data"+ songNum.value].song;
            currentSong.singer = musicData.src["data"+ songNum.value].singer;
            currentSong.YTLink = musicData.src["data"+ songNum.value].YTLink;
            if(playing.value === true){
                playing.value = !playing.value;
            }
        }

        const prevSong = ()=>{
            songNum.value -= 1 ; 
            musicCurrentTime.value = null ;
            processPercentage.value = null ;
            if(songNum.value < 1){
                songNum.value = 10 ;
            }
            currentSong.url = musicData.src["data"+ songNum.value].url;
            currentSong.song = musicData.src["data"+ songNum.value].song;
            currentSong.singer = musicData.src["data"+ songNum.value].singer;
            currentSong.YTLink = musicData.src["data"+ songNum.value].YTLink;
            if(playing.value === true){
                playing.value = !playing.value;
            }
        }
 
        onMounted(() => {
            axios.get('https://kb274483-practice-flaskapp.herokuapp.com/songAPI')
            .then(function (response) {
                musicData.src = response.data;
                currentSong.url = musicData.src.data1.url;
                currentSong.song = musicData.src.data1.song;
                currentSong.singer = musicData.src.data1.singer;
                currentSong.YTLink = musicData.src.data1.YTLink; 
            })
            .catch(function (error) {
                console.log(error);
            });
        })

        return { 
            musicData,
            currentSong,
            playing,
            playAndPause,
            nextSong,
            prevSong,
            musicDuration,
            musicCurrentTime,
            processPercentage,
            processPosition,
        }
    }         
}   
</script>

<template>
    <div class="miniPlayer">
        <div class="playContainer">
            <div class="musicInfo">
                <div class="img">
                    <img src="https://static.thenounproject.com/png/3607543-200.png" alt="discIcon" :class="{discIcon : playing}"> 
                    <audio :src="currentSong.url" id="musicPlayer" ></audio>
                </div>
                <div class="name">
                    <h2 class="songName"> {{currentSong.song}} </h2>
                    <h2 class="singer"> {{currentSong.singer}} </h2>
                    <div class="Link">
                        <a :href="currentSong.YTLink" target=_blank>
                            <img src="https://static.thenounproject.com/png/897668-200.png" alt="YoutubeLink" class="YoutubeLink">
                        </a>  
                    </div>
                </div>
            </div>
            <div class="controlPanel">
                <div class="prev btnFrame">
                    <span @click="prevSong">
                        <img src="https://static.thenounproject.com/png/4027732-84.png" 
                        alt="prevButton" >
                    </span>
                </div>
                <div class="play btnFrame">
                    <span @click="playAndPause">
                        <img src="https://static.thenounproject.com/png/4027766-84.png" 
                            alt="pauseButton" v-if="playing">
                        <img src="https://static.thenounproject.com/png/4027751-200.png" 
                            alt="playButton" v-else @click="currentTime ">
                    </span>
                </div>
                <div class="next btnFrame">
                    <span @click="nextSong">
                        <img src="https://static.thenounproject.com/png/4027744-84.png" 
                        alt="nextButton"  >
                    </span>
                </div>
            </div>
            
            <div class="process">
                <div class="currentTime"> {{musicCurrentTime}} </div>
                <div class="processBar" @click="processPosition">
                    <div class="percentage" :style="{ width : processPercentage + '%' }"> </div>
                </div>
                <div class="songTotalTime"> {{musicDuration}} </div>
            </div>
            <div class="copyright">Roy's web technical exercises 
                <a href="https://github.com/kb274483/Vue-MiniMusicPlayer" target=_blank >Github</a>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
    .miniPlayer{
        padding: 15px; margin-top: 100px;
        margin-right: auto; margin-left: auto;
        width: 360px; height: 500px;
        background-color: rgb(224, 229, 236);
        box-shadow: rgba(163, 177, 198, 0.5) 10px 10px 26px 0px, rgb(255, 255, 255) -18px -18px 36px 0px;
        border-radius: 41px;
    }
    //------------------------------------------------------------------------ 
    .musicInfo{
        margin: 30px 0px;
        display: flex;
        align-items: center;  
        justify-content: space-around;
        .img{
            background-color: rgb(224, 229, 236);
            box-shadow: rgba(163, 177, 198, 0.5) 3px 3px 6px 0px, rgb(255, 255, 255) -3px -3px 6px 0px;
            border-radius: 29px;
        }
        .discIcon{
            animation: rotate 2s linear infinite;   
        }
        @keyframes rotate {
            from{
                transform: rotate(0deg);
            }
            to{
                transform: rotate(360deg);
            } 
        }
        h2{
            margin: 20px;
            text-align: center;
            font-size: 20px;
            color: rgb(99, 99, 99);
        }
        .Link{
            text-align: right;
            margin-right: 20px;
            .YoutubeLink{
                width: 50px; height: 50px;
            }   
        }
        
    } 
    .controlPanel{
        margin-top: 30px;
        display: flex;
        justify-content: space-around;
        .btnFrame{
            width: 50px; height: 50px;
            background-color: rgb(224, 229, 236);
            box-shadow: rgba(163, 177, 198, 0.5) 3px 3px 6px 0px, rgb(255, 255, 255) -3px -3px 6px 0px;
            border-radius: 40px;
            &:hover{
                cursor: pointer;
                box-shadow: rgba(198, 197, 207, 0.5) 10px 10px 20px 0px inset, rgb(255, 255, 255) -10px -10px 20px 0px inset;
            }
            &:active{
                background-color: rgb(224, 229, 236);
                box-shadow: rgba(163, 177, 198, 0.5) 10px 10px 20px 0px inset, rgb(255, 255, 255) -10px -10px 20px 0px inset;
                border-radius: 40px;
            }
            span{
               display: flex; 
               justify-content: center;
               padding: 10px;
            }
        }
        img{
            width:30px; height:30px;
        }
        .play{
            width: 70px; height: 70px;
            img{
                width:50px; height:50px;
            }
        }

        
    }
    .process{
        margin-top: 20px;
        margin-right: auto; margin-left: auto;
        width: 300px;
        .processBar{
            width: 300px; height: 10px;
            margin: 10px 0px;
            background-color: rgb(199, 199, 199);
            border-radius: 20px;
            display: flex; 
            justify-content: space-between;
            &:hover{
                cursor: pointer;
            }
            .percentage{
                background-color: rgb(141, 141, 141);
                border-radius: 20px;
                transition: .5s all linear; 
            } 
        }
        .songTotalTime{
            text-align: right;
        }
    }
    .copyright{
        position:absolute ; bottom:0px; right:10px;
        color: rgb(141, 141, 141);
        font-size: 14px;
        margin: 30px;
        text-align: right;
        text-shadow: 2px 2px 2px rgb(182, 182, 182);
    }

    @media(max-width: 450px){
        .miniPlayer{
            margin-top: 50px;
            width: 300px; height: 500px;
        }
        .musicInfo{
            h2{
                font-size: 15px;
                margin: 10px;
            }
        }
    }
</style>
