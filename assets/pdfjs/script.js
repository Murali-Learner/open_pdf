pdfjsLib.GlobalWorkerOptions.workerSrc = "pdf.worker.js";

const container = document.getElementById("pdf-container");

let currentScale = 1;
let pdfDoc = null;

function base64ToUint8Array(base64) {
  const raw = atob(base64);
  const uint8Array = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) {
    uint8Array[i] = raw.charCodeAt(i);
  }
  return uint8Array;
}

function renderPage(pageNum) {
  pdfDoc.getPage(pageNum).then((page) => {
    const viewport = page.getViewport({ scale: 1 });
    const containerWidth = container.clientWidth - 40; // Subtract padding
    const scale = containerWidth / viewport.width;
    const scaledViewport = page.getViewport({ scale: scale });

    const pageDiv = document.createElement("div");
    pageDiv.className = "pdf-page";

    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    canvas.width = scaledViewport.width;
    canvas.height = scaledViewport.height;
    pageDiv.appendChild(canvas);

    const textLayer = document.createElement("div");
    textLayer.className = "textLayer";
    textLayer.style.width = `${scaledViewport.width}px`;
    textLayer.style.height = `${scaledViewport.height}px`;
    pageDiv.appendChild(textLayer);

    container.appendChild(pageDiv);

    const renderContext = {
      canvasContext: ctx,
      viewport: scaledViewport,
    };

    page.render(renderContext);

    page.getTextContent().then((textContent) => {
      pdfjsLib.renderTextLayer({
        textContent: textContent,
        container: textLayer,
        viewport: scaledViewport,
        textDivs: [],
      });
    });
  });
}

function renderPdf(pdfBase64) {
  pdfjsLib
    .getDocument({ data: base64ToUint8Array(pdfBase64) })
    .promise.then((pdf) => {
      pdfDoc = pdf;

      for (let i = 1; i <= pdf.numPages; i++) {
        renderPage(i, currentScale);
      }
    });

  const style = document.createElement("style");
  style.textContent = `
        .textLayer {
            position: absolute;
            left: 0;
            top: 0;
            right: 0;
            bottom: 0;
            overflow: scroll;
            opacity: 0.2;
            line-height: 1.0;
        }

        .textLayer > span {
            color: transparent;
            position: absolute;
            white-space: pre;
            cursor: text;
            transform-origin: 0% 0%;
        }

        .textLayer ::selection {
            background: rgba(0,0,255,0.6);
        }
    `;
  document.head.appendChild(style);
}
