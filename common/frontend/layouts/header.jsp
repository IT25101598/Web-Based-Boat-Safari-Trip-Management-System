<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : "Sail Lanka | Luxury Ocean Safari & Catamaran Charters"}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/footer.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>

<c:if test="${isHomePage or pageContext.request.requestURI.endsWith('/home') or pageContext.request.servletPath == '/home' or pageContext.request.servletPath == '/'}">
<!-- Compact Floating Maritime Safety Alert Side Badge / Docked Pill (Home Page Only) -->
<div id="emergencySideBadge" class="emergency-side-badge ${not empty activeAlerts ? 'active' : ''}" style="position: fixed !important; right: 0 !important; top: 130px !important; z-index: 1050 !important;" role="region" aria-label="Maritime Safety Advisory">
    <!-- Collapsed Pill (docks to right screen edge) -->
    <button id="emergencyBadgeToggle" class="emergency-badge-tab" type="button" aria-expanded="false" title="Click to view Maritime Safety Advisory">
        <span class="badge-beacon"></span>
        <i class="fa-solid fa-triangle-exclamation"></i>
        <span class="badge-tab-text">Safety Alert</span>
        <span id="emergencyBadgeCount" class="badge-counter">${not empty activeAlerts ? activeAlerts.size() : 1}</span>
    </button>

    <!-- Expanded Flyout Card -->
    <div id="emergencyBadgeFlyout" class="emergency-badge-flyout" aria-hidden="true">
        <div class="flyout-header">
            <div class="flyout-title-wrap">
                <i class="fa-solid fa-shield-halved"></i>
                <span>Maritime Advisory</span>
            </div>
            <button id="emergencyBadgeClose" class="flyout-close-btn" type="button" aria-label="Minimize alert">&times;</button>
        </div>
        <div class="flyout-body">
            <div id="emergencyBadgeSeverity" class="flyout-badge ${not empty activeAlerts ? activeAlerts[0].severity.badgeClass : 'badge-danger'}">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span id="emergencyBadgeSeverityText">${not empty activeAlerts ? activeAlerts[0].severity.name() : 'HIGH'}</span>
            </div>
            <h4 id="emergencyBadgeTitle" class="flyout-title">
                ${not empty activeAlerts ? activeAlerts[0].title : 'Marine Advisory Broadcast Active'}
            </h4>
            <p id="emergencyBadgeMessage" class="flyout-message">
                ${not empty activeAlerts ? activeAlerts[0].message : 'Coast Guard & Maritime monitoring in progress.'}
            </p>
            <div class="flyout-footer">
                <a href="${pageContext.request.contextPath}/emergency" class="flyout-link">
                    View All Advisories <i class="fa-solid fa-arrow-right"></i>
                </a>
            </div>
        </div>
    </div>
</div>
</c:if>

<!-- Floating Glassmorphic Master Navigation -->
<header class="site-header">
    <div class="container nav-wrapper">
        <a href="${pageContext.request.contextPath}/home" class="site-logo">
            <div class="logo-symbol">
                <i class="fa-solid fa-sailboat"></i>
            </div>
            <div class="logo-text">
                <span class="logo-title">SAIL LANKA</span>
                <span class="logo-tagline">LUXURY OCEAN SAFARI</span>
            </div>
        </a>

        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/home"><i class="fa-solid fa-house"></i> Home</a></li>
            <li><a href="${pageContext.request.contextPath}/experiences"><i class="fa-solid fa-compass"></i> Experiences</a></li>
            <li><a href="${pageContext.request.contextPath}/destinations"><i class="fa-solid fa-map-location-dot"></i> Destinations</a></li>
            <li><a href="${pageContext.request.contextPath}/boats"><i class="fa-solid fa-anchor"></i> Fleet</a></li>
            <li><a href="${pageContext.request.contextPath}/schedules"><i class="fa-regular fa-calendar-days"></i> Departures</a></li>
            <c:if test="${currentUser != null && currentUser.role.staff}">
                <li><a href="${pageContext.request.contextPath}/safety-checks"><i class="fa-solid fa-clipboard-check"></i> Safety Checks</a></li>
            </c:if>
            <li><a href="${pageContext.request.contextPath}/emergency"><i class="fa-solid fa-tower-broadcast"></i> Safety Alerts</a></li>
            <c:if test="${currentUser != null && currentUser.role.staff}">
                <li><a href="${pageContext.request.contextPath}/admin/dashboard" style="color: var(--champagne-gold); font-weight: 700;"><i class="fa-solid fa-gauge-high"></i> Back-Office</a></li>
            </c:if>
        </ul>

        <div class="nav-actions">
            <a href="${pageContext.request.contextPath}/booking" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-ticket"></i> Book Cruise
            </a>

            <c:choose>
                <c:when test="${currentUser != null}">
                    <c:if test="${!currentUser.role.staff}">
                        <a href="${pageContext.request.contextPath}/my-bookings" class="btn btn-outline-gold btn-sm" title="My Bookings">
                            <i class="fa-solid fa-receipt"></i> My Bookings
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/profile" class="user-pill" title="View Account">
                        <i class="fa-solid fa-user-circle"></i>
                        <span>${currentUser.fullName}</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-gold btn-sm" title="Log Out">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-gold btn-sm">
                        <i class="fa-solid fa-user"></i> Login
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>

<!-- Flash Alerts Container -->
<div class="flash-container">
    <c:if test="${not empty sessionScope.flashSuccess}">
        <div class="alert alert-success">
            <i class="fa-solid fa-circle-check"></i>
            <span>${sessionScope.flashSuccess}</span>
            <button onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer;"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <c:remove var="flashSuccess" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.flashError}">
        <div class="alert alert-danger">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span>${sessionScope.flashError}</span>
            <button onclick="this.parentElement.remove()" style="background:none; border:none; color:inherit; cursor:pointer;"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <c:remove var="flashError" scope="session" />
    </c:if>
</div>
