import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transformation"
// Handles real-time transformation preview with error handling
export default class extends Controller {
  static targets = ["selector", "input", "output", "status", "error", "errorMessage", "copyButton"]

  connect() {
    this.loadAvailableTransformations()
  }

  async loadAvailableTransformations() {
    try {
      const response = await fetch('/transformations/available')
      const data = await response.json()
      
      this.populateSelector(data.transformations)
    } catch (error) {
      console.error('Failed to load transformations:', error)
      this.showError('Failed to load available transformations')
    }
  }

  populateSelector(transformations) {
    // Clear existing options except the first one
    this.selectorTarget.innerHTML = '<option value="">Select a transformation...</option>'
    
    transformations.forEach(transformation => {
      const option = document.createElement('option')
      option.value = transformation.name
      option.textContent = transformation.display_name
      this.selectorTarget.appendChild(option)
    })
  }

  async transform() {
    const transformationName = this.selectorTarget.value
    const inputText = this.inputTarget.value

    // Clear previous state
    this.hideError()
    this.statusTarget.textContent = ''

    if (!transformationName || !inputText.trim()) {
      this.outputTarget.value = ''
      this.hideCopyButton()
      return
    }

    // Show loading state
    this.statusTarget.textContent = 'Transforming...'
    this.statusTarget.className = 'text-sm text-blue-600'

    try {
      const response = await fetch('/transformations/preview', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          name: transformationName,
          input: inputText
        })
      })

      const data = await response.json()

      if (data.success) {
        this.outputTarget.value = data.result
        this.statusTarget.textContent = '✓ Transformed'
        this.statusTarget.className = 'text-sm text-green-600'
        this.showCopyButton()
      } else {
        this.showError(data.error || 'Transformation failed')
        this.outputTarget.value = ''
        this.hideCopyButton()
      }
    } catch (error) {
      console.error('Transformation error:', error)
      this.showError('Network error occurred during transformation')
      this.outputTarget.value = ''
      this.hideCopyButton()
    }
  }

  copy() {
    if (this.outputTarget.value) {
      navigator.clipboard.writeText(this.outputTarget.value)
        .then(() => {
          const originalText = this.copyButtonTarget.textContent
          this.copyButtonTarget.textContent = 'Copied!'
          setTimeout(() => {
            this.copyButtonTarget.textContent = originalText
          }, 1000)
        })
        .catch(err => {
          console.error('Failed to copy:', err)
        })
    }
  }

  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorTarget.classList.remove('hidden')
    this.statusTarget.textContent = ''
  }

  hideError() {
    this.errorTarget.classList.add('hidden')
  }

  showCopyButton() {
    this.copyButtonTarget.style.display = 'block'
  }

  hideCopyButton() {
    this.copyButtonTarget.style.display = 'none'
  }
}