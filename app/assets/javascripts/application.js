document.addEventListener("click", function (event) {
  var target = event.target;
  var openTrigger = target.closest("[data-modal-open]");
  var closeTrigger = target.closest("[data-modal-close]");
  var createSectionTrigger = target.closest("[data-create-section]");
  var addVideoTrigger = target.closest("[data-add-video]");
  var addImageTrigger = target.closest("[data-add-image]");
  var addTextTrigger = target.closest("[data-add-text]");

  function openModal(modal) {
    modal.hidden = false;
    modal.style.display = "flex";
  }

  function hideModal(modal) {
    modal.hidden = true;
    modal.style.display = "none";
  }

  function setSectionContentVisibility(sectionBlock, selectedType) {
    if (!sectionBlock) return;

    var contentGroups = sectionBlock.querySelectorAll("[data-content-group]");
    contentGroups.forEach(function (group) {
      if (!selectedType) {
        group.hidden = false;
        return;
      }

      var groupType = group.getAttribute("data-content-group");
      group.hidden = groupType !== selectedType;
    });
  }

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

  if (openTrigger) {
    var modalId = openTrigger.getAttribute("data-modal-open");
    var modal = document.querySelector("[data-modal='" + modalId + "']");
    if (!modal) return;
    openModal(modal);
    return;
  }

  var contentSwitchTrigger = target.closest("[data-content-switch]");
  if (contentSwitchTrigger) {
    var panelKey = contentSwitchTrigger.getAttribute("data-content-switch");
    var modalContainer = contentSwitchTrigger.closest("[data-modal]");
    if (!modalContainer) return;

    var panels = modalContainer.querySelectorAll("[data-content-panel]");
    panels.forEach(function (panel) {
      var isCurrent = panel.getAttribute("data-content-panel") === panelKey;
      panel.hidden = !isCurrent;
    });
    return;
  }

  if (closeTrigger) {
    var closeModalId = closeTrigger.getAttribute("data-modal-close");
    var closeModalElement = document.querySelector("[data-modal='" + closeModalId + "']");
    if (!closeModalElement) return;
    hideModal(closeModalElement);
    return;
  }

  if (createSectionTrigger) {
    var selectedType = createSectionTrigger.getAttribute("data-create-section");
    var sectionsContainer = document.querySelector("[data-sections-container]");
    var template = document.getElementById("section-template");
    if (!sectionsContainer || !template) return;

    var sectionToken = Date.now().toString() + Math.random().toString().slice(2, 6);
    var html = template.innerHTML.replace(/NEW_SECTION/g, sectionToken);
    sectionsContainer.insertAdjacentHTML("beforeend", html);

    var sectionBlocks = sectionsContainer.querySelectorAll("[data-section-block]");
    var latestSection = sectionBlocks[sectionBlocks.length - 1];
    if (latestSection) {
      latestSection.setAttribute("data-selected-content-type", selectedType);
      setSectionContentVisibility(latestSection, selectedType);

      if (selectedType === "video") {
        var addVideoBtn = latestSection.querySelector("[data-add-video]");
        if (addVideoBtn) addVideoBtn.click();
      } else if (selectedType === "image") {
        var addImageBtn = latestSection.querySelector("[data-add-image]");
        if (addImageBtn) addImageBtn.click();
      } else if (selectedType === "text") {
        var addTextBtn = latestSection.querySelector("[data-add-text]");
        if (addTextBtn) addTextBtn.click();
      }
    }

    var pickerModal = document.querySelector("[data-modal='course-section-picker']");
    if (pickerModal) {
      hideModal(pickerModal);
    }
    return;
  }

  if (addVideoTrigger) {
    var sectionBlock = addVideoTrigger.closest("[data-section-block]");
    if (!sectionBlock) return;

    var videoContainer = sectionBlock.querySelector("[data-videos-container]");
    var videoTemplate = sectionBlock.querySelector("template[data-video-template]");
    if (!videoContainer || !videoTemplate) return;

    var videoToken = Date.now().toString() + Math.random().toString().slice(2, 6);
    var videoHtml = videoTemplate.innerHTML.replace(/NEW_VIDEO/g, videoToken);
    videoContainer.insertAdjacentHTML("beforeend", videoHtml);
    return;
  }

  if (addImageTrigger) {
    var imageSectionBlock = addImageTrigger.closest("[data-section-block]");
    if (!imageSectionBlock) return;

    var imageContainer = imageSectionBlock.querySelector("[data-images-container]");
    var imageTemplate = imageSectionBlock.querySelector("template[data-image-template]");
    if (!imageContainer || !imageTemplate) return;

    var imageToken = Date.now().toString() + Math.random().toString().slice(2, 6);
    var imageHtml = imageTemplate.innerHTML.replace(/NEW_IMAGE/g, imageToken);
    imageContainer.insertAdjacentHTML("beforeend", imageHtml);
    return;
  }

  if (addTextTrigger) {
    var textSectionBlock = addTextTrigger.closest("[data-section-block]");
    if (!textSectionBlock) return;

    var textContainer = textSectionBlock.querySelector("[data-texts-container]");
    var textTemplate = textSectionBlock.querySelector("template[data-text-template]");
    if (!textContainer || !textTemplate) return;

    var textToken = Date.now().toString() + Math.random().toString().slice(2, 6);
    var textHtml = textTemplate.innerHTML.replace(/NEW_TEXT/g, textToken);
    textContainer.insertAdjacentHTML("beforeend", textHtml);
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

document.addEventListener("click", function (event) {
  var target = event.target;
  if (!target.classList || !target.classList.contains("modal-backdrop")) return;
  target.hidden = true;
  target.style.display = "none";
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

function initAutoOpenModals() {
  var autoOpenModals = document.querySelectorAll("[data-modal][data-open-on-load='true']");
  autoOpenModals.forEach(function (modal) {
    modal.hidden = false;
    modal.style.display = "flex";
  });
}

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
document.addEventListener("DOMContentLoaded", initAutoOpenModals);
document.addEventListener("turbo:load", initAutoOpenModals);
