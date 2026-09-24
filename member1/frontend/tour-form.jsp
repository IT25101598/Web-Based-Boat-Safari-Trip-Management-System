<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tour Editor | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<style>
/* Typeable Route Combobox Styling */
.route-combobox-wrapper {
    position: relative;
    width: 100%;
}

.route-input-container {
    position: relative;
    display: flex;
    align-items: center;
}

.route-input-container .route-icon-left {
    position: absolute;
    left: 14px;
    color: var(--champagne-gold);
    font-size: 15px;
    pointer-events: none;
    z-index: 2;
}

.route-input-container input.route-search-input {
    width: 100%;
    padding: 10px 65px 10px 38px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    font-size: 14px;
    color: var(--text-main);
    background-color: #FFFFFF;
    transition: var(--transition);
}

.route-input-container input.route-search-input:focus {
    border-color: var(--champagne-gold);
    box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.2);
    outline: none;
}

.route-input-actions {
    position: absolute;
    right: 8px;
    display: flex;
    align-items: center;
    gap: 4px;
    z-index: 3;
}

.route-action-btn {
    background: transparent;
    border: none;
    cursor: pointer;
    color: var(--text-light);
    padding: 6px 8px;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    transition: var(--transition);
}

.route-action-btn:hover {
    color: var(--navy-primary);
    background: #F1F5F9;
}

.route-dropdown-menu {
    position: absolute;
    top: calc(100% + 4px);
    left: 0;
    right: 0;
    background: #FFFFFF;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    box-shadow: 0 12px 28px rgba(11, 37, 69, 0.16);
    max-height: 270px;
    overflow-y: auto;
    z-index: 1000;
    display: none;
}

.route-dropdown-menu.show {
    display: block;
}

.route-option-item {
    padding: 10px 14px;
    cursor: pointer;
    border-bottom: 1px solid #F1F5F9;
    transition: background 0.15s ease, border-left 0.15s ease;
}

.route-option-item:last-child {
    border-bottom: none;
}

.route-option-item:hover, .route-option-item.active-hover {
    background-color: rgba(212, 175, 55, 0.09);
    border-left: 3px solid var(--champagne-gold);
}

.route-option-item.selected {
    background-color: rgba(0, 119, 182, 0.08);
    border-left: 3px solid var(--marine-blue);
}

.route-option-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
}

.route-option-title {
    font-weight: 600;
    font-size: 13.5px;
    color: var(--navy-primary);
}

.route-time-badge {
    background: rgba(212, 175, 55, 0.18);
    color: #9A6B00;
    font-weight: 700;
    font-size: 11px;
    padding: 3px 8px;
    border-radius: 4px;
    white-space: nowrap;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.route-option-meta {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 12px;
    color: var(--text-muted);
    margin-top: 4px;
}

.route-meta-dist {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    font-weight: 500;
}

.route-meta-desc {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    max-width: 250px;
    color: #94A3B8;
}

.route-no-results {
    padding: 16px;
    text-align: center;
    color: var(--text-muted);
    font-size: 13px;
}

.route-selection-preview {
    margin-top: 6px;
    display: none;
    align-items: center;
    gap: 10px;
    font-size: 12.5px;
}

.route-preview-badge {
    background: rgba(2, 128, 144, 0.1);
    color: var(--ocean-teal);
    font-weight: 600;
    padding: 3px 10px;
    border-radius: 6px;
    display: inline-flex;
    align-items: center;
    gap: 5px;
}
</style>

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container">
        <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">${tour.id != null ? 'Edit Safari Tour' : 'Create New Safari Tour'}</h1>
        <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Tour package management, route itineraries, and pricing configuration.</p>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 800px;">
        <div class="card">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/admin/tours" method="POST">
                    <input type="hidden" name="csrf_token" value="${csrfToken}">
                    <c:if test="${tour.id != null}">
                        <input type="hidden" name="id" value="${tour.id}">
                    </c:if>

                    <div class="form-group">
                        <label class="form-label">Tour Title</label>
                        <input type="text" name="title" value="${tour.title}" class="form-control" required placeholder="e.g. Mirissa Blue Whale & Dolphin Catamaran Safari">
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label">Category</label>
                            <select name="tourType" class="form-control">
                                <c:forEach var="tt" items="${tourTypes}">
                                    <option value="${tt.name()}" ${tour.tourType == tt ? 'selected' : ''}>${tt.title}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="routeSearchInput">
                                Sailing Route <span style="font-size: 11px; color: var(--text-muted); font-weight: normal;">(Type or select with sailing time)</span>
                            </label>
                            <div class="route-combobox-wrapper" id="routeCombobox">
                                <div class="route-input-container">
                                    <i class="fa-solid fa-compass route-icon-left"></i>
                                    <input type="text" id="routeSearchInput" class="form-control route-search-input" 
                                           placeholder="Type route name, distance, or sailing time..." autocomplete="off">
                                    <input type="hidden" name="routeId" id="routeId" value="${tour.routeId != null ? tour.routeId : ''}" required>
                                    <div class="route-input-actions">
                                        <button type="button" class="route-action-btn" id="clearRouteBtn" title="Clear selection" style="display: none;">
                                            <i class="fa-solid fa-xmark"></i>
                                        </button>
                                        <button type="button" class="route-action-btn" id="toggleRouteBtn" title="Show all sailing routes">
                                            <i class="fa-solid fa-chevron-down" id="routeChevronIcon"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="route-dropdown-menu" id="routeDropdownMenu">
                                    <c:forEach var="r" items="${routes}">
                                        <div class="route-option-item" 
                                             data-id="${r.id}" 
                                             data-name="${r.name}" 
                                             data-duration="${r.durationHours}" 
                                             data-distance="${r.distanceNm}"
                                             data-highlights="${r.highlights}">
                                            <div class="route-option-header">
                                                <span class="route-option-title">${r.name}</span>
                                                <span class="route-time-badge">
                                                    <i class="fa-regular fa-clock"></i> ${r.durationHours} hrs sailing time
                                                </span>
                                            </div>
                                            <div class="route-option-meta">
                                                <span class="route-meta-dist"><i class="fa-solid fa-route" style="color: #94A3B8;"></i> ${r.distanceNm} NM</span>
                                                <c:if test="${not empty r.highlights}">
                                                    <span class="route-meta-desc">&bull; ${r.highlights}</span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                    <div class="route-no-results" id="routeNoResults" style="display: none;">
                                        <i class="fa-regular fa-circle-question"></i> No matching sailing routes found.
                                    </div>
                                </div>

                                <div class="route-selection-preview" id="routeSelectionPreview">
                                    <span class="route-preview-badge" id="routeTimeBadge">
                                        <i class="fa-regular fa-clock"></i> Sailing Time: <strong id="routePreviewDuration" style="margin-left: 2px;"></strong> hrs
                                    </span>
                                    <span style="color: var(--text-muted); font-size: 12px;" id="routeDistBadge">
                                        <i class="fa-solid fa-water"></i> Distance: <strong id="routePreviewDistance"></strong> NM
                                    </span>
                                </div>
                            </div>

                            <!-- Progressive fallback for non-JS environments -->
                            <noscript>
                                <select name="routeId" class="form-control" style="margin-top: 8px;">
                                    <c:forEach var="r" items="${routes}">
                                        <option value="${r.id}" ${tour.routeId == r.id ? 'selected' : ''}>
                                            ${r.name} — ${r.durationHours} hrs sailing time (${r.distanceNm} NM)
                                        </option>
                                    </c:forEach>
                                </select>
                            </noscript>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px;">
                        <div class="form-group">
                            <label class="form-label">Duration (Hours)</label>
                            <input type="number" step="0.5" name="durationHours" id="durationHoursInput" value="${tour.durationHours > 0 ? tour.durationHours : 4.0}" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Base Price (LKR)</label>
                            <input type="number" step="100" name="basePrice" value="${tour.basePrice.amount}" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Max Passengers</label>
                            <input type="number" name="maxPassengers" value="${tour.maxPassengers > 0 ? tour.maxPassengers : 25}" class="form-control" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Full Tour Description</label>
                        <textarea name="description" class="form-control" rows="4" required placeholder="Detailed voyage itinerary and highlights">${tour.description}</textarea>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Inclusions (Comma-separated)</label>
                        <input type="text" name="inclusions" value="${tour.inclusions}" class="form-control" placeholder="Gourmet breakfast, Ceylon tea, Binoculars, Life jackets">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Exclusions</label>
                        <input type="text" name="exclusions" value="${tour.exclusions}" class="form-control" placeholder="Hotel transfers, Alcoholic beverages">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Special Instructions & Operational Directives</label>
                        <textarea name="specialInstructions" class="form-control" rows="3" placeholder="Special marine safety notices, dietary accommodations, attire requirements, or wildlife interaction protocols..."><c:out value="${tour.specialInstructions}" /></textarea>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px;">
                        <a href="${pageContext.request.contextPath}/admin/tours" class="btn btn-outline-navy">Cancel</a>
                        <button type="submit" class="btn btn-gold">
                            <i class="fa-solid fa-floppy-disk"></i> Save Safari Tour
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const routeInput = document.getElementById("routeSearchInput");
    const routeIdInput = document.getElementById("routeId");
    const dropdownMenu = document.getElementById("routeDropdownMenu");
    const toggleBtn = document.getElementById("toggleRouteBtn");
    const clearBtn = document.getElementById("clearRouteBtn");
    const chevronIcon = document.getElementById("routeChevronIcon");
    const noResults = document.getElementById("routeNoResults");
    const previewContainer = document.getElementById("routeSelectionPreview");
    const previewDuration = document.getElementById("routePreviewDuration");
    const previewDistance = document.getElementById("routePreviewDistance");
    const durationInput = document.getElementById("durationHoursInput");
    const routeItems = Array.from(document.querySelectorAll(".route-option-item"));
    let activeIndex = -1;

    function openDropdown() {
        dropdownMenu.classList.add("show");
        if (chevronIcon) {
            chevronIcon.classList.remove("fa-chevron-down");
            chevronIcon.classList.add("fa-chevron-up");
        }
    }

    function closeDropdown() {
        dropdownMenu.classList.remove("show");
        if (chevronIcon) {
            chevronIcon.classList.remove("fa-chevron-up");
            chevronIcon.classList.add("fa-chevron-down");
        }
        activeIndex = -1;
        updateActiveItem();
    }

    function selectRoute(item, autoSyncDuration = true) {
        if (!item) return;
        const id = item.getAttribute("data-id");
        const name = item.getAttribute("data-name");
        const duration = item.getAttribute("data-duration");
        const distance = item.getAttribute("data-distance");

        routeIdInput.value = id;
        routeInput.value = name + " (" + duration + " hrs sailing time - " + distance + " NM)";
        routeInput.setCustomValidity("");

        // Highlight selected item in list
        routeItems.forEach(i => i.classList.remove("selected"));
        item.classList.add("selected");

        // Show live badge
        if (previewDuration) previewDuration.textContent = duration;
        if (previewDistance) previewDistance.textContent = distance;
        if (previewContainer) previewContainer.style.display = "flex";
        if (clearBtn) clearBtn.style.display = "block";

        // Auto-synchronize the Duration (Hours) field with the route's sailing time!
        if (autoSyncDuration && durationInput && duration) {
            durationInput.value = parseFloat(duration);
            durationInput.style.borderColor = "var(--ocean-teal)";
            durationInput.style.boxShadow = "0 0 0 3px rgba(2, 128, 144, 0.2)";
            setTimeout(() => { 
                durationInput.style.borderColor = ""; 
                durationInput.style.boxShadow = "";
            }, 900);
        }

        closeDropdown();
    }

    function filterRoutes(query) {
        const q = (query || "").trim().toLowerCase();
        let visibleCount = 0;

        routeItems.forEach(item => {
            const name = (item.getAttribute("data-name") || "").toLowerCase();
            const duration = (item.getAttribute("data-duration") || "").toLowerCase();
            const distance = (item.getAttribute("data-distance") || "").toLowerCase();
            const highlights = (item.getAttribute("data-highlights") || "").toLowerCase();

            const matches = !q || name.includes(q) || duration.includes(q) || distance.includes(q) || highlights.includes(q);
            if (matches) {
                item.style.display = "block";
                visibleCount++;
            } else {
                item.style.display = "none";
            }
        });

        if (visibleCount === 0) {
            noResults.style.display = "block";
        } else {
            noResults.style.display = "none";
        }
        activeIndex = -1;
        updateActiveItem();
    }

    function updateActiveItem() {
        const visibleItems = routeItems.filter(i => i.style.display !== "none");
        visibleItems.forEach((i, idx) => {
            if (idx === activeIndex) {
                i.classList.add("active-hover");
                i.scrollIntoView({ block: "nearest" });
            } else {
                i.classList.remove("active-hover");
            }
        });
    }

    if (routeInput) {
        routeInput.addEventListener("focus", function() {
            openDropdown();
            filterRoutes(this.value);
        });

        routeInput.addEventListener("input", function() {
            openDropdown();
            filterRoutes(this.value);
            if (clearBtn) clearBtn.style.display = this.value ? "block" : "none";

            // If user is typing, check for exact case-insensitive name match
            const q = this.value.trim().toLowerCase();
            const exactMatch = routeItems.find(i => (i.getAttribute("data-name") || "").toLowerCase() === q);
            if (exactMatch) {
                selectRoute(exactMatch, true);
            } else {
                routeIdInput.value = "";
                if (previewContainer) previewContainer.style.display = "none";
            }
        });

        routeInput.addEventListener("keydown", function(e) {
            const visibleItems = routeItems.filter(i => i.style.display !== "none");
            if (e.key === "ArrowDown") {
                e.preventDefault();
                if (!dropdownMenu.classList.contains("show")) {
                    openDropdown();
                    filterRoutes(this.value);
                    return;
                }
                if (visibleItems.length > 0) {
                    activeIndex = (activeIndex + 1) % visibleItems.length;
                    updateActiveItem();
                }
            } else if (e.key === "ArrowUp") {
                e.preventDefault();
                if (visibleItems.length > 0) {
                    activeIndex = (activeIndex - 1 + visibleItems.length) % visibleItems.length;
                    updateActiveItem();
                }
            } else if (e.key === "Enter") {
                if (dropdownMenu.classList.contains("show") && activeIndex >= 0 && activeIndex < visibleItems.length) {
                    e.preventDefault();
                    selectRoute(visibleItems[activeIndex], true);
                }
            } else if (e.key === "Escape") {
                closeDropdown();
            }
        });
    }

    routeItems.forEach(item => {
        item.addEventListener("click", function() {
            selectRoute(this, true);
        });
    });

    if (toggleBtn) {
        toggleBtn.addEventListener("click", function(e) {
            e.stopPropagation();
            if (dropdownMenu.classList.contains("show")) {
                closeDropdown();
            } else {
                routeInput.focus();
                openDropdown();
                filterRoutes("");
            }
        });
    }

    if (clearBtn) {
        clearBtn.addEventListener("click", function(e) {
            e.stopPropagation();
            routeInput.value = "";
            routeIdInput.value = "";
            if (previewContainer) previewContainer.style.display = "none";
            clearBtn.style.display = "none";
            routeItems.forEach(i => {
                i.classList.remove("selected");
                i.style.display = "block";
            });
            noResults.style.display = "none";
            routeInput.focus();
            openDropdown();
        });
    }

    document.addEventListener("click", function(e) {
        const comboboxEl = document.getElementById("routeCombobox");
        if (comboboxEl && !comboboxEl.contains(e.target)) {
            closeDropdown();
            if (routeInput && !routeIdInput.value && routeInput.value.trim() !== "") {
                routeInput.setCustomValidity("Please select a valid sailing route from the dropdown list.");
            }
        }
    });

    // Form submission validation
    if (routeInput) {
        const form = routeInput.closest("form");
        if (form) {
            form.addEventListener("submit", function(e) {
                if (!routeIdInput.value || parseInt(routeIdInput.value) <= 0) {
                    e.preventDefault();
                    routeInput.setCustomValidity("Please choose or type a valid sailing route.");
                    routeInput.reportValidity();
                    routeInput.focus();
                    openDropdown();
                    filterRoutes("");
                } else {
                    routeInput.setCustomValidity("");
                }
            });
        }
    }

    // Pre-fill on page load (for edit mode or validation redirect)
    if (routeIdInput && routeIdInput.value) {
        const initialRouteId = routeIdInput.value;
        const matched = routeItems.find(i => i.getAttribute("data-id") === initialRouteId);
        if (matched) {
            const isEditExisting = ${tour.id != null ? 'true' : 'false'};
            selectRoute(matched, !isEditExisting);
        }
    }
});
</script>

<jsp:include page="../layouts/footer.jsp" />
