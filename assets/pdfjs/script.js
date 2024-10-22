pdfjsLib.GlobalWorkerOptions.workerSrc = "pdf.worker.js";

const container = document.getElementById("pdf-container");
const contextMenu = document.getElementById('context-menu');

let longPressTimer;
const longPressDuration = 500; // 500ms for long press
let isLongPress = false;

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
// Show context menu when long press is detected
function showContextMenu(event) {
  const selectedText = window.getSelection().toString().trim();
  if (!selectedText) return; // Show menu only if text is selected

  event.preventDefault(); // Prevent default browser context menu

  // Get dimensions of the context menu
  const menuWidth = contextMenu.offsetWidth;
  const menuHeight = contextMenu.offsetHeight;

  // Position the menu at the cursor's position
  contextMenu.style.left = `${Math.min(event.pageX, window.innerWidth - menuWidth)}px`;
  contextMenu.style.top = `${Math.min(event.pageY, window.innerHeight - menuHeight)}px`;
  contextMenu.style.display = 'block';
}




// Handle long press for text selection
container.addEventListener('mousedown', (event) => {
  // Start a timer for the long press
  isLongPress = false;
  longPressTimer = setTimeout(() => {
    isLongPress = true;
    const selectedText = window.getSelection().toString().trim();
    console.log(`selectedText ${selectedText}`);

    if (selectedText) {
      showContextMenu(event); // Show context menu after long press
    }
  }, longPressDuration);
});

container.addEventListener('mouseup', () => {
  // Clear the timer on mouse up to avoid long press action
  clearTimeout(longPressTimer);
});

container.addEventListener('mouseleave', () => {
  // Clear the timer if the mouse leaves the container area
  clearTimeout(longPressTimer);
});

// Hide the custom context menu
function hideContextMenu() {
  const selectedText = window.getSelection().toString().trim();

  console.log("this is click event" + selectedText);
  contextMenu.style.display = 'none';
}

container.addEventListener('contextmenu', (event) => {
  const selectedText = window.getSelection().toString().trim();
  if (selectedText) {
    showContextMenu(event); // Show menu if text is selected
  } else {
    hideContextMenu(); // Otherwise, hide the custom menu
  }
});

// Hide the custom context menu when clicking anywhere else
window.addEventListener('click', hideContextMenu);
console.log(`copy-text ${document.getElementById('copy-text')}`);
const selectedText = window.getSelection().toString().trim();
// Add functionality for menu items
document.getElementById('copy-text').addEventListener('click', () => {

  window.flutter_inappwebview.callHandler("copyText", selectedText);


  // hideContextMenu();
});

console.log(`search dictionary ${document.getElementById('search-dictionary')}`);

document.getElementById('search-dictionary').addEventListener('click', () => {

  window.flutter_inappwebview.callHandler("searchDictionary", null);


  // hideContextMenu();
});

// Make sure the context menu hides when clicking elsewhere
container.addEventListener('click', hideContextMenu);

function renderPage(pageNum, scale = currentScale) {
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
