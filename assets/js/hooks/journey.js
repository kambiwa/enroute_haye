// assets/js/hooks/journey_hooks.js
// Hooks for the Journey LiveView planner.
// Import and register these in your app.js Hooks object.

/**
 * CountUp — animates the budget number when the summary step renders.
 * Usage: <div id="cost-counter" phx-hook="CountUp" data-target="3500">$0</div>
 */
export const CountUp = {
  mounted() {
    this.animate();
  },

  updated() {
    this.animate();
  },

  animate() {
    const target = parseInt(this.el.dataset.target || "0", 10);
    let current = 0;
    const step = Math.ceil(target / 60);
    const iv = setInterval(() => {
      current = Math.min(current + step, target);
      this.el.textContent = "$" + current.toLocaleString();
      if (current >= target) clearInterval(iv);
    }, 16);
  },
};

/**
 * CopyItinerary — copies inner text of a target element to clipboard.
 * Usage: <button phx-hook="CopyItinerary" data-target="itinerary-text">Copy</button>
 */
export const CopyItinerary = {
  mounted() {
    this.el.addEventListener("click", () => {
      const targetId = this.el.dataset.target;
      const target = document.getElementById(targetId);
      if (!target) return;

      navigator.clipboard
        .writeText(target.innerText)
        .then(() => {
          const original = this.el.textContent;
          this.el.textContent = "✓ Copied!";
          setTimeout(() => (this.el.textContent = original), 1800);
        })
        .catch(() => {
          // Fallback for older browsers
          const range = document.createRange();
          range.selectNodeContents(target);
          window.getSelection().removeAllRanges();
          window.getSelection().addRange(range);
          document.execCommand("copy");
          window.getSelection().removeAllRanges();
        });
    });
  },
};

/**
 * StepSlide — optional: smooth scroll-to-top on step change.
 * Usage: <div id="step-X" phx-hook="StepSlide">
 */
export const StepSlide = {
  updated() {
    this.el.scrollIntoView({ behavior: "smooth", block: "start" });
  },
};

// ── Registration helper ────────────────────────────────────────────────────
// In your app.js, do:
//
//   import { CountUp, CopyItinerary, StepSlide } from "./hooks/journey_hooks";
//   const Hooks = { CountUp, CopyItinerary, StepSlide };
//   let lv = new LiveSocket("/live", Socket, { hooks: Hooks, ... });