import ApplicationController from 'controllers/application_controller'

export default class extends ApplicationController {
  static values = { index: Number }
  connect() {
    super.connect()
    this.index= 0
    this.items = Array.from(document.querySelectorAll('.autocomplete-item'));
    this.list = document.getElementById('autocompleteList');
  }

  input() {
    this.showOrHideList();
    this.filterItems()
    this.revealFilteredItems()
    this.resetIndex()
    this.highlightIndex()
  }

  showOrHideList() {
    if (this.element.value[0] === '/') {
      this.list.classList.remove('hidden');
    } else {
      this.list.classList.add('hidden');
    }
  }

  filterItems() {
    this.filteredItems = this.items.filter(item => item.dataset.name.startsWith(this.element.value))
  }

  revealFilteredItems() {
    this.items.forEach(item => item.classList.add('hidden'))
    this.filteredItems.forEach(item => item.classList.remove('hidden'))
  }

  highlightIndex() {
    this.items.forEach(item => item.classList.remove('bg-blue-900'))
    if (this.filteredItems[this.index]) {
      this.filteredItems[this.index].classList.add('bg-blue-900')
    }
  }

  resetIndex() {
    this.index = 0
  }

  keydown(event) {
    if (event.key === 'Tab' || event.key === 'ArrowRight') {
      event.preventDefault()
      this.completeHighlightedSelection()
    }
    if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.decrementIndex()
    }
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.incrementIndex()
    }
  }

  decrementIndex() {
    this.index = Math.max(0, this.index - 1)
    this.highlightIndex()
  }

  incrementIndex() {
    this.index = Math.min(this.filteredItems.length - 1, this.index + 1)
    this.highlightIndex()
  }

  completeHighlightedSelection() {
    this.element.value = this.filteredItems[this.index].dataset.name
    this.blur()
  }

  blur() {
    setTimeout(() => {
      this.list.classList.add('hidden');
    }, 100);
  }
}
