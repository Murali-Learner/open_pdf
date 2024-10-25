pdfjsLib.GlobalWorkerOptions.workerSrc = "pdf.worker.js";

const container = document.getElementById("pdf-container");
const contextMenu = document.getElementById("context-menu");

let currentScale = 1;
let pdfDoc = null;
let currentPage = 1;
let selectedPdfText = "";


document.addEventListener('contextmenu', (e) => {
  e.preventDefault();
});

function showContextMenu(event) {
  event.preventDefault();
  event.stopPropagation();

  const selectedText = window.getSelection().toString().trim();
  if (!selectedText) {
    hideContextMenu();
    return;
  }

  selectedPdfText = selectedText;


  const x = event.pageX;
  const y = event.pageY;


  const menuWidth = contextMenu.offsetWidth;
  const menuHeight = contextMenu.offsetHeight;
  const windowWidth = window.innerWidth;
  const windowHeight = window.innerHeight;


  const adjustedX = Math.min(x, windowWidth - menuWidth - 10);
  const adjustedY = Math.min(y, windowHeight - menuHeight - 10);

  contextMenu.style.left = `${adjustedX}px`;
  contextMenu.style.top = `${adjustedY}px`;
  contextMenu.style.display = 'block';
  contextMenu.style.zIndex = '1000';
}

function hideContextMenu() {
  contextMenu.style.display = 'none';
  selectedPdfText = "";
}



document.addEventListener('contextmenu', (event) => {
  const selection = window.getSelection();
  const selectedText = selection.toString().trim();

  if (selectedText) {
    showContextMenu(event);
  }
});


document.addEventListener('click', (event) => {
  if (!contextMenu.contains(event.target)) {
    hideContextMenu();
  }
});


document.getElementById("copy-text").addEventListener("click", () => {
  window.flutter_inappwebview.callHandler("copyText", selectedPdfText);
  hideContextMenu();
});

document.getElementById("search-dictionary").addEventListener("click", () => {
  window.flutter_inappwebview.callHandler("searchDictionary", selectedPdfText);
  hideContextMenu();
});

document.getElementById("search-wikipedia").addEventListener("click", () => {
  window.flutter_inappwebview.callHandler("searchWikipedia", selectedPdfText);
  hideContextMenu();
});

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
    canvas.style.width = `${scaledViewport.width}px`;
    canvas.style.height = `${scaledViewport.height}px`;
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

    page.render(renderContext).promise.then(() => {
      window.flutter_inappwebview.callHandler("loadingListener", false);

      return page.getTextContent();
    }).then((textContent) => {
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

function base64ToUint8Array(base64) {
  const raw = atob(base64);
  const uint8Array = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) {
    uint8Array[i] = raw.charCodeAt(i);
  }
  return uint8Array;
}

function jumpToPage(pageNum) {
  currentPage = pageNum;
  renderPage(currentPage);
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