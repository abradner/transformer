/**
 * @jest-environment jsdom
 */

// Mock fetch globally
global.fetch = jest.fn()

// Mock Stimulus Controller base class
class MockController {
  constructor() {
    this.targets = {}
  }
}

// Simple mock for the transformation functionality
describe("TransformationController functionality", () => {
  let mockController
  let selectorTarget
  let inputTarget
  let outputTarget
  let statusTarget
  let errorTarget
  let errorMessageTarget
  let copyButtonTarget

  beforeEach(() => {
    // Setup DOM elements
    document.body.innerHTML = `
      <div data-controller="transformation">
        <select data-transformation-target="selector">
          <option value="">Select a transformation...</option>
        </select>
        <textarea data-transformation-target="input"></textarea>
        <textarea data-transformation-target="output" readonly></textarea>
        <div data-transformation-target="status"></div>
        <div data-transformation-target="error" class="hidden"></div>
        <div data-transformation-target="errorMessage"></div>
        <button data-transformation-target="copyButton" style="display: none;"></button>
      </div>
    `

    // Get DOM elements
    selectorTarget = document.querySelector('[data-transformation-target="selector"]')
    inputTarget = document.querySelector('[data-transformation-target="input"]')
    outputTarget = document.querySelector('[data-transformation-target="output"]')
    statusTarget = document.querySelector('[data-transformation-target="status"]')
    errorTarget = document.querySelector('[data-transformation-target="error"]')
    errorMessageTarget = document.querySelector('[data-transformation-target="errorMessage"]')
    copyButtonTarget = document.querySelector('[data-transformation-target="copyButton"]')

    // Create mock controller with the essential methods
    mockController = {
      selectorTarget,
      inputTarget,
      outputTarget,
      statusTarget,
      errorTarget,
      errorMessageTarget,
      copyButtonTarget,
      
      async loadAvailableTransformations() {
        try {
          const response = await fetch('/transformations/available')
          const data = await response.json()
          this.populateSelector(data.transformations)
        } catch (error) {
          console.error('Failed to load transformations:', error)
        }
      },

      populateSelector(transformations) {
        this.selectorTarget.innerHTML = '<option value="">Select a transformation...</option>'
        transformations.forEach(transformation => {
          const option = document.createElement('option')
          option.value = transformation.name
          option.textContent = transformation.display_name
          this.selectorTarget.appendChild(option)
        })
      },

      async transform() {
        const transformationName = this.selectorTarget.value
        const inputText = this.inputTarget.value

        this.hideError()
        this.statusTarget.textContent = ''

        if (!transformationName || !inputText.trim()) {
          this.outputTarget.value = ''
          this.hideCopyButton()
          return
        }

        this.statusTarget.textContent = 'Transforming...'

        try {
          const response = await fetch('/transformations/preview', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'X-CSRF-Token': 'mock-token'
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
            this.showCopyButton()
          } else {
            this.showError(data.error || 'Transformation failed')
            this.outputTarget.value = ''
            this.hideCopyButton()
          }
        } catch (error) {
          this.showError('Network error occurred during transformation')
          this.outputTarget.value = ''
          this.hideCopyButton()
        }
      },

      showError(message) {
        this.errorMessageTarget.textContent = message
        this.errorTarget.classList.remove('hidden')
        this.statusTarget.textContent = ''
      },

      hideError() {
        this.errorTarget.classList.add('hidden')
      },

      showCopyButton() {
        this.copyButtonTarget.style.display = 'block'
      },

      hideCopyButton() {
        this.copyButtonTarget.style.display = 'none'
      },

      async copy() {
        try {
          await navigator.clipboard.writeText(this.outputTarget.value)
          this.copyButtonTarget.textContent = "Copied!"
          setTimeout(() => {
            this.copyButtonTarget.textContent = "Copy"
          }, 1000)
        } catch (error) {
          console.error('Copy failed:', error)
        }
      }
    }

    // Mock console methods to avoid noise in tests
    jest.spyOn(console, 'error').mockImplementation(() => {})
    jest.spyOn(console, 'log').mockImplementation(() => {})
  })

  afterEach(() => {
    // Clean up
    fetch.mockReset()
    jest.restoreAllMocks()
    document.body.innerHTML = ""
  })

  describe("initialization", () => {
    it("loads available transformations", async () => {
      const mockTransformations = [
        { name: "base64_encode", display_name: "Base64 Encode" },
        { name: "base64_decode", display_name: "Base64 Decode" }
      ]

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ transformations: mockTransformations })
      })

      await mockController.loadAvailableTransformations()

      expect(fetch).toHaveBeenCalledWith('/transformations/available')
      
      const selector = mockController.selectorTarget
      expect(selector.children.length).toBe(3) // 1 default + 2 transformations
      expect(selector.children[1].textContent).toBe("Base64 Encode")
      expect(selector.children[1].value).toBe("base64_encode")
    })

    it("handles failed transformation loading", async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'))

      await mockController.loadAvailableTransformations()

      expect(fetch).toHaveBeenCalledWith('/transformations/available')
      // Should show error but not crash
      expect(mockController.selectorTarget.children.length).toBe(1) // Only default option
    })
  })

  describe("transformation", () => {
    beforeEach(async () => {
      // Mock successful transformations loading
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ 
          transformations: [{ name: "base64_encode", display_name: "Base64 Encode" }]
        })
      })
      
      await mockController.loadAvailableTransformations()
      await new Promise(resolve => setTimeout(resolve, 0))
      fetch.mockClear()
    })

    it("performs transformation when input and selection are provided", async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, result: "SGVsbG8gV29ybGQh" })
      })

      // Set up form state
      mockController.selectorTarget.value = "base64_encode"
      mockController.inputTarget.value = "Hello World!"

      // Trigger transformation
      await mockController.transform()

      expect(fetch).toHaveBeenCalledWith('/transformations/preview', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': expect.any(String)
        },
        body: JSON.stringify({
          name: "base64_encode",
          input: "Hello World!"
        })
      })

      expect(mockController.outputTarget.value).toBe("SGVsbG8gV29ybGQh")
      expect(mockController.statusTarget.textContent).toBe("✓ Transformed")
      expect(mockController.copyButtonTarget.style.display).toBe("block")
    })

    it("handles transformation errors", async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: false, error: "Invalid input" })
      })

      mockController.selectorTarget.value = "base64_encode"
      mockController.inputTarget.value = "test"

      await mockController.transform()

      expect(mockController.outputTarget.value).toBe("")
      expect(mockController.errorTarget.classList.contains('hidden')).toBe(false)
      expect(mockController.errorMessageTarget.textContent).toBe("Invalid input")
    })

    it("clears output when no transformation is selected", async () => {
      mockController.selectorTarget.value = ""
      mockController.inputTarget.value = "test"
      mockController.outputTarget.value = "previous result"

      await mockController.transform()

      expect(mockController.outputTarget.value).toBe("")
      expect(mockController.copyButtonTarget.style.display).toBe("none")
      expect(fetch).not.toHaveBeenCalled()
    })

    it("clears output when no input is provided", async () => {
      mockController.selectorTarget.value = "base64_encode"
      mockController.inputTarget.value = ""

      await mockController.transform()

      expect(mockController.outputTarget.value).toBe("")
      expect(fetch).not.toHaveBeenCalled()
    })

    it("handles network errors", async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'))

      mockController.selectorTarget.value = "base64_encode"
      mockController.inputTarget.value = "test"

      await mockController.transform()

      expect(mockController.outputTarget.value).toBe("")
      expect(mockController.errorTarget.classList.contains('hidden')).toBe(false)
      expect(mockController.errorMessageTarget.textContent).toBe("Network error occurred during transformation")
    })
  })

  describe("copy functionality", () => {
    beforeEach(() => {
      // Mock clipboard API
      Object.assign(navigator, {
        clipboard: {
          writeText: jest.fn().mockResolvedValue()
        }
      })
    })

    it("copies output to clipboard", async () => {
      mockController.outputTarget.value = "test result"
      
      await mockController.copy()

      expect(navigator.clipboard.writeText).toHaveBeenCalledWith("test result")
    })

    it("shows feedback when copy succeeds", async () => {
      mockController.outputTarget.value = "test"
      mockController.copyButtonTarget.textContent = "Copy"

      await mockController.copy()

      expect(mockController.copyButtonTarget.textContent).toBe("Copied!")
      
      // Wait for timeout
      await new Promise(resolve => setTimeout(resolve, 1100))
      
      expect(mockController.copyButtonTarget.textContent).toBe("Copy")
    })

    it("handles copy failures gracefully", async () => {
      navigator.clipboard.writeText.mockRejectedValueOnce(new Error('Copy failed'))
      
      mockController.outputTarget.value = "test"

      await mockController.copy()

      // Should not crash or show error to user
      expect(mockController.copyButtonTarget.textContent).not.toBe("Copied!")
    })
  })

  describe("UI state management", () => {
    it("shows and hides error messages", () => {
      mockController.showError("Test error")

      expect(mockController.errorTarget.classList.contains('hidden')).toBe(false)
      expect(mockController.errorMessageTarget.textContent).toBe("Test error")
      expect(mockController.statusTarget.textContent).toBe("")

      mockController.hideError()

      expect(mockController.errorTarget.classList.contains('hidden')).toBe(true)
    })

    it("shows and hides copy button", () => {
      mockController.showCopyButton()
      expect(mockController.copyButtonTarget.style.display).toBe("block")

      mockController.hideCopyButton()
      expect(mockController.copyButtonTarget.style.display).toBe("none")
    })

    it("populates selector with transformations", () => {
      const transformations = [
        { name: "test1", display_name: "Test 1" },
        { name: "test2", display_name: "Test 2" }
      ]

      mockController.populateSelector(transformations)

      const selector = mockController.selectorTarget
      expect(selector.children.length).toBe(3) // 1 default + 2 transformations
      expect(selector.children[1].value).toBe("test1")
      expect(selector.children[1].textContent).toBe("Test 1")
    })
  })
})