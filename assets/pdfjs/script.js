pdfjsLib.GlobalWorkerOptions.workerSrc = "pdf.worker.js";

const container = document.getElementById("pdf-container");

let currentScale = 1;
let pdfDoc = null;
let currentPage = 1;
let startX, startY, endX, endY;
let initialPinchDistance = 0;
let isPinching = false;
let isZoomed = false;
let lastTapTime = 0;

function base64ToUint8Array(base64) {
  const raw = atob(base64);
  const uint8Array = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) {
    uint8Array[i] = raw.charCodeAt(i);
  }
  return uint8Array;
}

// Render the PDF page with the current scale
function renderPage(pageNum, scale = currentScale) {
  pdfDoc.getPage(pageNum).then((page) => {
    const viewport = page.getViewport({ scale: 1 });
    const containerWidth = container.clientWidth - 40; // Subtract padding
    const containerHeight = window.innerHeight; // Subtract some space for margins
    const scaleWidth = containerWidth / viewport.width;
    const scaleHeight = containerHeight / viewport.height;
    const baseScale = Math.min(scaleWidth, scaleHeight);
    const scaledViewport = page.getViewport({ scale: baseScale * scale });

    container.innerHTML = ""; // Clear previous content

    const pageDiv = document.createElement("div");
    pageDiv.className = "pdf-page";
    pageDiv.id = `pdfPage${pageNum}`;

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

// Load the PDF document from base64 data
function renderPdf(pdfBase64) {
  pdfjsLib
    .getDocument({ data: base64ToUint8Array(pdfBase64) })
    .promise.then((pdf) => {
      pdfDoc = pdf;
      renderPage(currentPage);
    })
    .catch((error) => {
      console.error("Error loading PDF:", error);
    });
}

// Handle pinch to zoom
function handlePinch(e) {
  e.preventDefault();
  if (e.touches.length === 2) {
    const touch1 = e.touches[0];
    const touch2 = e.touches[1];
    const distance = Math.hypot(
      touch1.clientX - touch2.clientX,
      touch1.clientY - touch2.clientY
    );

    if (initialPinchDistance === 0) {
      initialPinchDistance = distance;
    } else {
      const scale = distance / initialPinchDistance;
      currentScale = Math.max(1, Math.min(3, currentScale * scale));
      renderPage(currentPage, currentScale);
    }
    isPinching = true;
  }
}

function handleSwipe() {
  const swipeThreshold = 50;
  if (!isZoomed) {
    if (Math.abs(startX - endX) > Math.abs(startY - endY)) {
      // Horizontal swipe
      if (startX - endX > swipeThreshold && currentPage < pdfDoc.numPages) {
        currentPage++;
        renderPage(currentPage);
      } else if (endX - startX > swipeThreshold && currentPage > 1) {
        currentPage--;
        renderPage(currentPage);
      }
    } else {
      // Vertical swipe
      if (startY - endY > swipeThreshold && currentPage < pdfDoc.numPages) {
        currentPage++;
        renderPage(currentPage);
      } else if (endY - startY > swipeThreshold && currentPage > 1) {
        currentPage--;
        renderPage(currentPage);
      }
    }
  }
}

container.addEventListener("touchstart", (e) => {
  startX = e.touches[0].clientX;
  startY = e.touches[0].clientY;
  initialPinchDistance = 0;
  isPinching = false;

  const currentTime = new Date().getTime();
  const tapLength = currentTime - lastTapTime;
  if (tapLength < 300 && tapLength > 0) {
    e.preventDefault();
    currentScale = isZoomed ? 1 : 2;
    isZoomed = !isZoomed;
    renderPage(currentPage, currentScale);
  }
  lastTapTime = currentTime;
});

container.addEventListener("touchmove", (e) => {
  if (e.touches.length === 2) {
    handlePinch(e);
  } else if (isZoomed) {
    // Pan logic can be implemented if necessary
  } else {
    endX = e.touches[0].clientX;
    endY = e.touches[0].clientY;
  }
});

container.addEventListener("touchend", (e) => {
  if (!isPinching && !isZoomed) {
    handleSwipe();
  }
  initialPinchDistance = 0;
  isPinching = false;
});
