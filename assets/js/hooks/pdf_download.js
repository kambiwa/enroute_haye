// ─────────────────────────────────────────────────────────────────────────────
// FILE: assets/js/hooks/pdf_download.js
//
// LiveView hook that listens for the "download_pdf" push event from the server.
// When received, it decodes the base64 PDF and triggers a browser download.
// ─────────────────────────────────────────────────────────────────────────────

export const PDFDownload = {
  mounted() {
    this.handleEvent("download_pdf", ({ data, filename }) => {
      // Decode base64 → binary → Blob
      const binary = atob(data);
      const bytes = new Uint8Array(binary.length);
      for (let i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
      }
      const blob = new Blob([bytes], { type: "application/pdf" });
      const url = URL.createObjectURL(blob);

      // Trigger download
      const a = document.createElement("a");
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);

      // Also open in new tab for in-browser preview
      window.open(url, "_blank");

      // Clean up after a short delay
      setTimeout(() => URL.revokeObjectURL(url), 10_000);
    });
  },
};

// ─────────────────────────────────────────────────────────────────────────────
// REGISTRATION — add PDFDownload to your hooks object in app.js:
//
//   import { PDFDownload } from "./hooks/pdf_download"
//
//   let liveSocket = new LiveSocket("/live", Socket, {
//     hooks: {
//       StepSlide,
//       CountUp,
//       CopyItinerary,
//       PDFDownload,   // ← add this
//     },
//     ...
//   })
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// CSS ADDITIONS — append to your journey.css / app.css
// ─────────────────────────────────────────────────────────────────────────────

/*
.pdf-ready-badge {
  background: linear-gradient(135deg, #1E4035 0%, #0D1B15 100%);
  border: 1px solid var(--gold);
  border-radius: 10px;
  color: #fff;
  text-align: center;
  padding: 12px 20px;
  font-size: 0.95rem;
  margin: 16px 0 8px;
  letter-spacing: 0.02em;
}

.btn-generate {
  width: 100%;
  padding: 16px;
  margin-top: 18px;
  background: linear-gradient(135deg, var(--gold) 0%, #a07828 100%);
  color: #0D1B15;
  font-weight: 700;
  font-size: 1.05rem;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  letter-spacing: 0.04em;
  transition: opacity 0.2s, transform 0.15s;
}

.btn-generate:hover:not(:disabled) {
  opacity: 0.88;
  transform: translateY(-1px);
}

.btn-generate:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.generating {
  display: flex;
  align-items: center;
  gap: 14px;
  background: rgba(201, 168, 76, 0.08);
  border: 1px solid var(--gold);
  border-radius: 10px;
  padding: 14px 18px;
  margin-top: 16px;
  color: var(--gold);
  font-size: 0.95rem;
}

.spinner {
  width: 22px;
  height: 22px;
  border: 3px solid rgba(201, 168, 76, 0.25);
  border-top-color: var(--gold);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  flex-shrink: 0;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-box {
  background: rgba(180, 40, 40, 0.12);
  border: 1px solid #c44;
  border-radius: 8px;
  color: #e88;
  padding: 12px 16px;
  margin-top: 14px;
  font-size: 0.9rem;
}
*/