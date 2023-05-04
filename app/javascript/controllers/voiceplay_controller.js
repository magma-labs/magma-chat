import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    super.connect()
    this.avatar = this.element;
    this.audio = this.element.nextSibling;

    this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const source = this.audioContext.createMediaElementSource(this.audio);
    this.analyser = this.audioContext.createAnalyser();
    this.analyser.fftSize = 32;

    source.connect(this.analyser);
    this.analyser.connect(this.audioContext.destination);
    this.dataArray = new Uint8Array(this.analyser.frequencyBinCount);

    this.avatar.addEventListener("click", () => {
      if (this.audio.paused) {
        this.audio.play();
        this.audioContext.resume();
        this.avatar.classList.add("voiceshake");
      } else {
        this.audio.pause();
        this.avatar.classList.remove("voiceshake");
        this.avatar.style.transform = `scale(1)`;
      }
    });

    this.audio.addEventListener("canplay", () => {
      this.avatar.classList.remove("transition");
      this.avatar.classList.remove("voiceshake");
    });

    this.audio.addEventListener("ended", () => {
      this.avatar.style.transform = `scale(1)`;
      this.avatar.classList.add("transition");
      this.avatar.classList.remove("voiceshake");
    });

    this.updateAnimation = this.updateAnimation.bind(this);
    this.updateAnimation();
  }

  updateAnimation() {
    if (!this.audio.paused) {
      this.analyser.getByteFrequencyData(this.dataArray);
      const volume = this.dataArray.reduce((a, b) => a + b) / this.dataArray.length;
      const shakeIntensity = (volume / 255) * 1.1; // Scale the intensity to a desired range (e.g., 3 degrees)
      console.log(shakeIntensity);
      this.avatar.style.transform = `scale(${shakeIntensity + 1})`;
    }

    requestAnimationFrame(this.updateAnimation.bind(this));
  }


}
