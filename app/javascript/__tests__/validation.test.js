// Jest configuration validation test
describe('Testing Framework Validation', () => {
  describe('Jest configuration', () => {
    it('loads test environment correctly', () => {
      expect(typeof window).toBe('object');
      expect(typeof document).toBe('object');
    });

    it('includes testing library matchers', () => {
      const element = document.createElement('div');
      element.textContent = 'Hello World';
      document.body.appendChild(element);

      expect(element).toBeInTheDocument();
      expect(element).toHaveTextContent('Hello World');

      // Clean up
      element.remove();
    });

    it('includes custom transformation matchers', () => {
      const mockTransformation = {
        apply: jest.fn((input) => input.toUpperCase())
      };

      expect(mockTransformation).toTransformStringTo('hello', 'HELLO');
    });
  });

  describe('Module resolution', () => {
    it('supports ES6 imports', () => {
      expect(typeof Promise).toBe('function');
      expect(typeof Array.from).toBe('function');
    });

    it('has proper mock utilities available', () => {
      expect(typeof jest.fn).toBe('function');
      expect(typeof jest.mock).toBe('function');
    });
  });

  describe('DOM environment', () => {
    it('provides browser-like environment', () => {
      expect(window.ResizeObserver).toBeDefined();
      expect(window.matchMedia).toBeDefined();
    });

    it('can create and manipulate DOM elements', () => {
      const button = document.createElement('button');
      button.textContent = 'Click me';
      document.body.appendChild(button);

      expect(button).toBeInTheDocument();
      expect(button.textContent).toBe('Click me');

      button.remove();
    });
  });
});
