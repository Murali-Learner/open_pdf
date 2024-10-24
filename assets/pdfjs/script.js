pdfjsLib.GlobalWorkerOptions.workerSrc = "pdf.worker.js";

const container = document.getElementById("pdf-container");
const contextMenu = document.getElementById("context-menu");

let currentScale = 1;
let pdfDoc = null;
let currentPage = 1;
let startX, startY, endX, endY;
let initialPinchDistance = 0;
let isPinching = false;
let isZoomed = false;
let lastTapTime = 0;
var selectedPdfText = "";

function base64ToUint8Array(base64) {
  const raw = atob(base64);
  const uint8Array = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) {
    uint8Array[i] = raw.charCodeAt(i);
  }
  return uint8Array;
}

function showContextMenu(event) {
  const selectedText = window.getSelection().toString().trim();
  if (!selectedText) return;

  event.preventDefault();

  const menuWidth = contextMenu.offsetWidth;
  const menuHeight = contextMenu.offsetHeight;

  contextMenu.style.left = `${Math.min(
    event.pageX,
    window.innerWidth - menuWidth
  )}px`;
  contextMenu.style.top = `${Math.min(
    event.pageY,
    window.innerHeight - menuHeight
  )}px`;
  contextMenu.style.display = "block";
}

function hideContextMenu() {
  contextMenu.style.display = "none";
  selectedPdfText = "";
}

container.addEventListener("contextmenu", (event) => {
  selectedPdfText = window.getSelection().toString().trim();

  if (selectedPdfText) {
    showContextMenu(event);
  } else {
    hideContextMenu();
  }
});

window.addEventListener("click", hideContextMenu);
console.log(`copy-text ${document.getElementById("copy-text")}`);
const selectedText = window.getSelection().toString().trim();

document.getElementById("copy-text").addEventListener("click", () => {
  window.flutter_inappwebview.callHandler("copyText", selectedPdfText);
});

console.log(
  `search dictionary ${document.getElementById("search-dictionary")}`
);

document.getElementById("search-dictionary").addEventListener("click", () => {
  window.flutter_inappwebview.callHandler("searchDictionary", selectedPdfText);
});

document.getElementById("search-wikipedia").addEventListener("click", () => {
  window.flutter_inappwebview.callHandler("searchWikipedia", selectedPdfText);
});

container.addEventListener("click", hideContextMenu);

function renderPage(pageNum, scale = currentScale) {
  window.flutter_inappwebview.callHandler("loadingListener", true);

  pdfDoc.getPage(pageNum).then((page) => {
    const viewport = page.getViewport({ scale: 1 });
    const containerWidth = container.clientWidth - 40;
    const containerHeight = window.innerHeight;
    const scaleWidth = containerWidth / viewport.width;
    const scaleHeight = containerHeight / viewport.height;
    const baseScale = Math.min(scaleWidth, scaleHeight);
    const scaledViewport = page.getViewport({ scale: baseScale * scale });

    container.innerHTML = "";

    const pageDiv = document.createElement("div");
    pageDiv.className = "pdf-page";
    pageDiv.id = `pdfPage${pageNum}`;

    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");
    canvas.width = scaledViewport.width;
    canvas.height = scaledViewport.height;
    // var displayWidth = 1.5;
    // canvas.style.width = `${(viewport.width * displayWidth) / scale}px`;
    // canvas.style.height = `${(viewport.height * displayWidth) / scale}px`;
    pageDiv.appendChild(canvas);

    const textLayer = document.createElement("div");
    textLayer.className = "textLayer";
    textLayer.style.width = `${scaledViewport.width}px`;
    textLayer.style.height = `${scaledViewport.height}px`;
    pageDiv.appendChild(textLayer);

    container.appendChild(pageDiv);

    const renderContext = {
      canvasContext: ctx,
      intent: "print",
      viewport: scaledViewport,
    };

    page.render(renderContext);
    window.flutter_inappwebview.callHandler("loadingListener", false);

    page.getTextContent().then((textContent) => {
      pdfjsLib.renderTextLayer({
        textContent: textContent,
        container: textLayer,
        viewport: scaledViewport,
        textDivs: [],
      });
    });
  });
  window.flutter_inappwebview.callHandler("onPageChanged", pageNum);
}

function renderPdf(pdfBase64) {
  pdfjsLib
    .getDocument({ data: base64ToUint8Array(pdfBase64) })
    .promise.then((pdf) => {
      pdfDoc = pdf;
      renderPage(currentPage);
      window.flutter_inappwebview.callHandler("totalPdfPages", pdfDoc.numPages);
    })
    .catch((error) => {
      console.error("Error loading PDF:", error);
    });
}

function jumpToPage(pageNum) {
  renderPage(pageNum);
}

function changePage(isNextPage) {
  if (isNextPage && currentPage < pdfDoc.numPages) {
    currentPage++;
    renderPage(currentPage);
  } else if (!isNextPage && currentPage > 1) {
    currentPage--;
    renderPage(currentPage);
  }
}
