// Based on: <https://gist.github.com/OrionReed/4c3778ebc2b5026d2354359ca49077ca> by <https://github.com/OrionReed>
// 3D DOM viewer, copy-paste this into your console to visualise the DOM topographically.
// 3D Dom viewer, copy-paste this into your console to visualise the DOM as a stack of solid blocks.
// You can also minify and save it as a bookmarklet (https://www.freecodecamp.org/news/what-are-bookmarklets/)
(() => {
  // Configuration
  const SHOW_SIDES = false; // Display sides of DOM nodes?
  const COLOR_SURFACE = true; // Color tops of DOM nodes?
  const COLOR_RANDOM = false; // Use random colors?
  const COLOR_HUE = 190; // Hue for color generation (HSL)
  const MAX_ROTATION = 180; // Maximum rotation angle (degrees)
  const THICKNESS = 20; // Thickness of DOM layers
  const DISTANCE = 10000; // Perspective distance

  // --- Utility Functions ---
  const getRandomColor = () => {
    const hue = Math.floor(Math.random() * 360);
    const saturation = 50 + Math.floor(Math.random() * 30);
    const lightness = 40 + Math.floor(Math.random() * 30);
    return `hsl(${hue}, ${saturation}%, ${lightness}%)`;
  };

  const getDOMDepth = (element, currentDepth = 1) =>
    element.children.length === 0
      ? currentDepth
      : Math.max(
          ...Array.from(element.children).map((child) =>
            getDOMDepth(child, currentDepth + 1)
          )
        );

  const getColorByDepth = (depth, hue = 0, lighten = 0, maxDepth) =>
    `hsl(${hue}, 75%, ${
      Math.min(10 + depth * (1 + 60 / maxDepth), 90) + lighten
    }%)`;

  // --- DOM Manipulation Functions ---

  const createSideFace = (width, height, transform, transformOrigin) => {
    const face = document.createElement("div");
    face.classList.add("dom-3d-side-face"); // Use classList for better performance
    Object.assign(face.style, {
      transformStyle: "preserve-3d",
      backfaceVisibility: "hidden",
      position: "absolute",
      width: `${width}px`,
      height: `${height}px`,
      transform,
      transformOrigin,
      overflow: "hidden",
      willChange: "transform", // Improve rendering performance
    });
    return face;
  };

  const createSideFaces = (element, color) => {
    if (!SHOW_SIDES) return;

    const width = element.offsetWidth;
    const height = element.offsetHeight;
    const fragment = document.createDocumentFragment(); // Reduce DOM reflows

    fragment.appendChild(
      createSideFace(
        width,
        THICKNESS,
        `rotateX(-270deg) translateY(${-THICKNESS}px)`,
        "top"
      )
    ); // Top
    fragment.appendChild(
      createSideFace(THICKNESS, height, "rotateY(90deg)", "left")
    ); // Right
    fragment.appendChild(
      createSideFace(
        width,
        THICKNESS,
        `rotateX(-90deg) translateY(${THICKNESS}px)`,
        "bottom"
      )
    ); // Bottom
    fragment.appendChild(
      createSideFace(
        THICKNESS,
        height,
        `translateX(${-THICKNESS}px) rotateY(-90deg)`,
        "right"
      )
    ); // Left

    element.appendChild(fragment);
  };

  const traverseDOM = (
    parentNode,
    depthLevel = 0,
    offsetX = 0,
    offsetY = 0,
    maxDepth
  ) => {
    for (const childNode of parentNode.children) {
      const color = COLOR_RANDOM
        ? getRandomColor()
        : getColorByDepth(depthLevel, COLOR_HUE, -5, maxDepth);
      Object.assign(childNode.style, {
        transform: `translateZ(${THICKNESS}px)`,
        overflow: "visible",
        backfaceVisibility: "hidden",
        isolation: "isolate", // Better for stacking context
        transformStyle: "preserve-3d",
        backgroundColor: COLOR_SURFACE
          ? color
          : getComputedStyle(childNode).backgroundColor,
        willChange: "transform",
      });

      // Update offsets for absolute positioning within parent
      let updatedOffsetX = offsetX + childNode.offsetLeft;
      let updatedOffsetY = offsetY + childNode.offsetTop;
      createSideFaces(childNode, color);
      traverseDOM(
        childNode,
        depthLevel + 1,
        updatedOffsetX,
        updatedOffsetY,
        maxDepth
      );
    }
  };

  // --- Initialization ---
  const body = document.body;
  body.style.overflow = "hidden";
  body.style.transformStyle = "preserve-3d";
  body.style.perspective = `${DISTANCE}px`;
  const perspectiveOriginX = window.innerWidth / 2;
  const perspectiveOriginY = window.innerHeight / 2;
  body.style.perspectiveOrigin =
    body.style.transformOrigin = `${perspectiveOriginX}px ${perspectiveOriginY}px`;

  const domDepth = getDOMDepth(body);
  traverseDOM(body, 0, 0, 0, domDepth); // Pass calculated max depth

  // --- Mouse Interaction ---
  document.addEventListener("mousemove", (event) => {
    const rotationY =
      MAX_ROTATION * (1 - event.clientY / window.innerHeight) -
      MAX_ROTATION / 2;
    const rotationX =
      (MAX_ROTATION * event.clientX) / window.innerWidth - MAX_ROTATION / 2;
    body.style.transform = `rotateX(${rotationY}deg) rotateY(${rotationX}deg)`;
  });
})();
