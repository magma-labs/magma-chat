import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"];

  connect() {
    this.switchOnHash()
    document.addEventListener("stimulus-reflex:after", this.switchOnHash.bind(this))
  }

  switchOnHash() {
    console.log('switchOnHash')
    const hash = window.location.hash.substring(1);
    if (hash) {
      this.switchToTab(hash);
    }
  }

  switch(event) {
    event.preventDefault();
    const tabName = event.currentTarget.dataset.tabName;
    this.switchToTab(tabName);
  }

  switchToTab(tabName) {
    window.history.pushState(null, null, '#' + tabName);

    this.tabTargets.forEach((tab) => {
      if (tab.dataset.tabName === tabName) {
        tab.classList.add("active");
      } else {
        tab.classList.remove("active");
      }
    });

    this.contentTargets.forEach((content) => {
      if (content.dataset.tabName === tabName) {
        content.classList.remove("hidden");
      } else {
        content.classList.add("hidden");
      }
    });
  }
}
