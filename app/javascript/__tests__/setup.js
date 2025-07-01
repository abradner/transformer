// Jest setup file for React testing
import '@testing-library/jest-dom';

// Global test utilities and mocks
global.ResizeObserver = jest.fn().mockImplementation(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}));

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Custom matchers for transformation testing
expect.extend({
  toTransformStringTo(received, input, expectedOutput) {
    const pass = received.apply(input) === expectedOutput;
    if (pass) {
      return {
        message: () => `expected transformation NOT to convert "${input}" to "${expectedOutput}"`,
        pass: true,
      };
    } else {
      return {
        message: () => `expected transformation to convert "${input}" to "${expectedOutput}", but got "${received.apply(input)}"`,
        pass: false,
      };
    }
  },
});
