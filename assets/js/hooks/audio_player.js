export const Player = {
  mounted() {
    const audio = document.getElementById("audio-player")
    const playBtn = document.getElementById("play-btn")

    playBtn.addEventListener("click", () => {
      if(audio.paused){
        audio.play()
        playBtn.innerText = "⏸"
      }else{
        audio.pause()
        playBtn.innerText = "▶"
      }
    })
  }
}