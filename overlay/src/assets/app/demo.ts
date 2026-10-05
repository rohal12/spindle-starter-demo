// Exposed on window so passages can call it from {do} blocks.
function rollDice(sides: number): number {
  return 1 + Math.floor(Math.random() * sides);
}

declare global {
  interface Window {
    demo: { rollDice: typeof rollDice };
  }
}

window.demo = { rollDice };

export {};
