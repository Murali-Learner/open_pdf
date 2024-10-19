pdfjsLib.GlobalWorkerOptions.workerSrc = 'pdf.worker.js';

const container = document.getElementById('pdf-container');

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

// Render a single page
function renderPage(pageNum, scale = 1) {
    pdfDoc.getPage(pageNum).then(page => {
        const viewport = page.getViewport({ scale: scale });
        const aspectRatio = viewport.height / viewport.width;
        const viewportWidth = window.innerWidth * 0.9; // Set width to 90% of viewport
        const scaledHeight = viewportWidth * aspectRatio;

        // Create a new div for each page
        const pageDiv = document.createElement('div');
        pageDiv.style.position = 'relative';
        pageDiv.style.margin = '20px 0';  // Add margin between pages
        pageDiv.style.display = 'flex';
        pageDiv.style.flexDirection = 'column';  // Ensure vertical stacking
        pageDiv.style.alignItems = 'center';  // Center align the canvas and text layer

        // Create a canvas for each page
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        canvas.width = viewportWidth;
        canvas.height = scaledHeight;
        pageDiv.appendChild(canvas);

        // Create a text layer for each page
        const textLayer = document.createElement('div');
        textLayer.className = 'textLayer';
        textLayer.style.width = `${viewportWidth}px`;
        textLayer.style.height = `${scaledHeight}px`;
        pageDiv.appendChild(textLayer);

        container.appendChild(pageDiv); // Append the page div to the container

        const renderContext = {
            canvasContext: ctx,
            viewport: page.getViewport({ scale: viewportWidth / viewport.width })
        };

        // Render the PDF page into the canvas
        const renderTask = page.render(renderContext);

        // Render the text layer
        page.getTextContent().then(textContent => {
            pdfjsLib.renderTextLayer({
                textContent: textContent,
                container: textLayer,
                viewport: page.getViewport({ scale: viewportWidth / viewport.width }),
                textDivs: [],
                enhanceTextSelection: true,
            });
        });
    });
}

// Loop through and render all pages of the PDF
function renderPdf(pdfBase64) {
    pdfjsLib.getDocument({ data: base64ToUint8Array(pdfBase64) }).promise.then(pdf => {
        pdfDoc = pdf;

        // Loop through each page and render
        for (let i = 1; i <= pdf.numPages; i++) {
            renderPage(i, currentScale);
        }
    });

    const style = document.createElement('style');
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
            background: rgba(0,0,255,0.3);
        }
    `;
    document.head.appendChild(style);
}
