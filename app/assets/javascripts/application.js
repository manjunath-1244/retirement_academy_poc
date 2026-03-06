document.addEventListener("click", function (event) {
  var target = event.target;

  if (target.matches("[data-select-action]")) {
    var groupId = target.getAttribute("data-select-target");
    var group = document.getElementById(groupId);
    if (!group) return;

    var checkboxes = group.querySelectorAll("input[type='checkbox']");
    var shouldCheck = target.getAttribute("data-select-action") === "all";
    checkboxes.forEach(function (checkbox) {
      checkbox.checked = shouldCheck;
    });
    return;
  }

  if (target.matches("[data-add-section]")) {
    var sectionsContainer = document.querySelector("[data-sections-container]");
    var template = document.getElementById("section-template");
    if (!sectionsContainer || !template) return;

    var sectionToken = Date.now().toString();
    var html = template.innerHTML.replace(/NEW_SECTION/g, sectionToken);
    sectionsContainer.insertAdjacentHTML("beforeend", html);
    return;
  }

  if (target.matches("[data-add-video]")) {
    var sectionBlock = target.closest("[data-section-block]");
    if (!sectionBlock) return;

    var videoContainer = sectionBlock.querySelector("[data-videos-container]");
    var videoTemplate = sectionBlock.querySelector("template[data-video-template]");
    if (!videoContainer || !videoTemplate) return;

    var videoToken = Date.now().toString() + Math.random().toString().slice(2, 6);
    var videoHtml = videoTemplate.innerHTML.replace(/NEW_VIDEO/g, videoToken);
    videoContainer.insertAdjacentHTML("beforeend", videoHtml);
    return;
  }

  if (target.matches("[data-add-image]")) {
    var imageSectionBlock = target.closest("[data-section-block]");
    if (!imageSectionBlock) return;

    var imageContainer = imageSectionBlock.querySelector("[data-images-container]");
    var imageTemplate = imageSectionBlock.querySelector("template[data-image-template]");
    if (!imageContainer || !imageTemplate) return;

    var imageToken = Date.now().toString() + Math.random().toString().slice(2, 6);
    var imageHtml = imageTemplate.innerHTML.replace(/NEW_IMAGE/g, imageToken);
    imageContainer.insertAdjacentHTML("beforeend", imageHtml);
    return;
  }

  if (target.matches("[data-remove-nested]")) {
    var block = target.closest("[data-nested-item], [data-section-block]");
    if (!block) return;

    var destroyField = block.querySelector("[data-destroy-field]");
    if (destroyField) {
      destroyField.value = "1";
    }
    block.style.display = "none";
  }
});

document.addEventListener("change", function (event) {
  var target = event.target;
  if (!target.matches("[data-password-toggle-targets]")) return;

  var ids = (target.getAttribute("data-password-toggle-targets") || "").split(",");
  ids.forEach(function (id) {
    var field = document.getElementById(id.trim());
    if (!field) return;
    field.type = target.checked ? "text" : "password";
  });
});

function initCourseSort() {
  var list = document.querySelector("[data-course-sort-list]");
  if (!list || list.dataset.initialized === "true") return;
  list.dataset.initialized = "true";

  var draggableItems = list.querySelectorAll(".draggable-course");
  if (!draggableItems.length) return;

  var draggedItem = null;

  function persistOrder() {
    var reorderUrl = list.getAttribute("data-reorder-url");
    if (!reorderUrl) return;

    var ids = Array.prototype.map.call(
      list.querySelectorAll("[data-course-id]"),
      function (node) { return node.getAttribute("data-course-id"); }
    );

    var token = document.querySelector("meta[name='csrf-token']");
    fetch(reorderUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token ? token.getAttribute("content") : ""
      },
      body: JSON.stringify({ course_ids: ids })
    });
  }

  function afterElement(container, y) {
    var items = Array.prototype.slice.call(container.querySelectorAll(".draggable-course:not(.dragging)"));
    return items.reduce(function (closest, child) {
      var box = child.getBoundingClientRect();
      var offset = y - box.top - box.height / 2;
      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child };
      }
      return closest;
    }, { offset: Number.NEGATIVE_INFINITY, element: null }).element;
  }

  draggableItems.forEach(function (item) {
    item.addEventListener("dragstart", function () {
      draggedItem = item;
      item.classList.add("dragging");
    });

    item.addEventListener("dragend", function () {
      item.classList.remove("dragging");
      draggedItem = null;
      persistOrder();
    });
  });

  list.addEventListener("dragover", function (event) {
    event.preventDefault();
    if (!draggedItem) return;
    var nextItem = afterElement(list, event.clientY);
    if (nextItem == null) {
      list.appendChild(draggedItem);
    } else {
      list.insertBefore(draggedItem, nextItem);
    }
  });
}

document.addEventListener("DOMContentLoaded", initCourseSort);
document.addEventListener("turbo:load", initCourseSort);
