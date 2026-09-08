<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isHomePage" value="true" scope="request" />
<c:set var="pageTitle" value="Sail Lanka | Luxury Catamaran & Ocean Safari Experiences" />
<jsp:include page="../layouts/header.jsp" />

<style>
/* Safety Alert Floating Badge on Home Page */
.emergency-side-badge {
    position: fixed !important;
    right: 0 !important;
    top: 130px !important;
    z-index: 1050 !important;
    transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.35s ease !important;
}
.emergency-side-badge.scrolled-hidden {
    transform: translateX(125%) !important;
    opacity: 0 !important;
    pointer-events: none !important;
}

/* Hero Section */
.hero-section {
    min-height: 90vh;
    background: linear-gradient(135deg, rgba(7, 24, 44, 0.72) 0%, rgba(11, 37, 69, 0.40) 50%, rgba(7, 24, 44, 0.78) 100%),
                url('${pageContext.request.contextPath}/assets/img/hero-catamaran-sunset.jpg') center right/cover no-repeat;
    display: flex;
    align-items: center;
    position: relative;
    /* Pull up to remove double-offset from body padding-top + hero's own top padding */
    margin-top: -84px;
    padding-top: 160px;
    color: #FFFFFF;
}

.hero-content {
    max-width: 780px;
}

.hero-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 16px;
    background: rgba(212, 175, 55, 0.2);
    border: 1px solid var(--champagne-gold);
    border-radius: var(--radius-full);
    color: var(--gold-light);
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 1px;
    text-transform: uppercase;
    margin-bottom: 24px;
}

.hero-title {
    font-family: var(--font-serif);
    font-size: 54px;
    font-weight: 700;
    line-height: 1.15;
    color: #FFFFFF;
    margin-bottom: 20px;
    letter-spacing: -0.5px;
}

.hero-subtitle {
    font-size: 18px;
    color: #E2E8F0;
    line-height: 1.7;
    margin-bottom: 36px;
    font-weight: 300;
    text-wrap: balance;
    overflow-wrap: break-word;
}


.hero-cta {
    display: flex;
    gap: 16px;
    flex-wrap: wrap;
}

/* ── Hero Entrance Animations ── */
@keyframes heroFadeUp {
    from {
        opacity: 0;
        transform: translateY(28px) scale(0.97);
    }
    to {
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

@keyframes heroFadeIn {
    from { opacity: 0; }
    to   { opacity: 1; }
}

@keyframes heroBadgePop {
    0%   { opacity: 0; transform: translateY(16px) scale(0.88); }
    70%  { transform: translateY(-4px) scale(1.04); }
    100% { opacity: 1; transform: translateY(0) scale(1); }
}

.hero-anim-badge {
    animation: heroBadgePop 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) 0.15s both;
}

.hero-anim-title {
    animation: heroFadeUp 0.9s cubic-bezier(0.16, 1, 0.3, 1) 0.38s both;
}

.hero-anim-subtitle {
    animation: heroFadeUp 0.9s cubic-bezier(0.16, 1, 0.3, 1) 0.56s both;
}

.hero-anim-cta {
    animation: heroFadeUp 0.85s cubic-bezier(0.16, 1, 0.3, 1) 0.74s both;
}

.hero-anim-live {
    animation: heroFadeIn 1s ease 1.0s both;
}

/* Quick Search Floating Box */
.search-banner {
    margin-top: -50px;
    position: relative;
    z-index: 10;
}

.search-card {
    background: #FFFFFF;
    border-radius: var(--radius-lg);
    box-shadow: var(--shadow-lg);
    padding: 24px 32px;
    border: 1px solid rgba(212, 175, 55, 0.25);
}

.search-form {
    display: grid;
    grid-template-columns: 2fr 1.5fr 1fr 1.2fr;
    gap: 20px;
    align-items: flex-end;
}

/* Section Common */
.section {
    padding: 90px 0;
    position: relative;
    z-index: 1;
}

.section-title-wrap {
    text-align: center;
    max-width: 680px;
    margin: 0 auto 55px auto;
}

.section-eyebrow {
    font-size: 13px;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: var(--champagne-gold);
    font-weight: 700;
    margin-bottom: 10px;
}

.section-title {
    font-size: 36px;
    color: var(--navy-primary);
    font-weight: 800;
    margin-bottom: 14px;
}

.section-desc {
    color: var(--text-muted);
    font-size: 16px;
}

/* Tour Cards Grid */
.tour-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
    gap: 32px;
}

.tour-card {
    background: #FFFFFF;
    border-radius: var(--radius-md);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    border: 1px solid var(--border-color);
    transition: var(--transition);
    display: flex;
    flex-direction: column;
}

.tour-card:hover {
    transform: translateY(-6px);
    box-shadow: var(--shadow-lg);
    border-color: rgba(212, 175, 55, 0.4);
}

.tour-card-img {
    height: 230px;
    position: relative;
    background-size: cover;
    background-position: center;
}

.tour-card-badge {
    position: absolute;
    top: 16px;
    left: 16px;
    background: rgba(7, 24, 44, 0.85);
    backdrop-filter: blur(8px);
    color: var(--champagne-gold);
    padding: 4px 12px;
    border-radius: var(--radius-full);
    font-size: 12px;
    font-weight: 700;
    border: 1px solid var(--border-gold);
}

.tour-card-body {
    padding: 24px;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.tour-card-title {
    font-size: 20px;
    font-weight: 700;
    color: var(--navy-primary);
    margin-bottom: 10px;
    line-height: 1.35;
}

.tour-meta {
    display: flex;
    gap: 16px;
    margin-bottom: 14px;
    font-size: 13px;
    color: var(--text-muted);
}

.tour-meta span {
    display: flex;
    align-items: center;
    gap: 6px;
}

.tour-card-desc {
    font-size: 14px;
    color: var(--text-muted);
    line-height: 1.6;
    margin-bottom: 20px;
    flex-grow: 1;
}

.tour-card-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-top: 18px;
    border-top: 1px solid var(--border-color);
}

.tour-price-box {
    display: flex;
    flex-direction: column;
}

.tour-price-label {
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--text-light);
}

.tour-price-val {
    font-size: 22px;
    font-weight: 800;
    color: var(--navy-primary);
}

/* Fleet Showcase */
.fleet-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 26px;
}

.vessel-card {
    background: #FFFFFF;
    border-radius: var(--radius-md);
    border: 1px solid var(--border-color);
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    transition: var(--transition);
    display: flex;
    flex-direction: column;
}

.vessel-card:hover {
    transform: translateY(-5px);
    box-shadow: var(--shadow-md);
    border-color: var(--champagne-gold);
}

.vessel-card-img {
    width: 100%;
    height: 190px;
    background-size: cover;
    background-position: center;
    position: relative;
}

.vessel-card-body {
    padding: 20px;
    text-align: center;
    display: flex;
    flex-direction: column;
    flex: 1;
}

.vessel-reg-badge {
    display: inline-block;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 1px;
    color: var(--champagne-gold);
    background: rgba(212, 175, 55, 0.1);
    border: 1px solid rgba(212, 175, 55, 0.3);
    border-radius: var(--radius-full);
    padding: 3px 10px;
    margin-bottom: 10px;
}

/* Feature Highlights */
.feature-box {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 30px;
}

.feature-item {
    background: #FFFFFF;
    padding: 32px 26px;
    border-radius: var(--radius-md);
    border-top: 3px solid var(--champagne-gold);
    box-shadow: var(--shadow-sm);
}

.feature-item h3 {
    font-size: 18px;
    margin: 14px 0 10px 0;
}

@media (max-width: 992px) {
    .search-form { grid-template-columns: 1fr 1fr; }
    .hero-title { font-size: 40px; }
    .feature-box { grid-template-columns: 1fr; }
}

@media (max-width: 576px) {
    .search-form { grid-template-columns: 1fr; }
    .hero-title { font-size: 32px; }
    .hero-subtitle { font-size: 15px; line-height: 1.6; margin-bottom: 24px; }
}
</style>

<!-- Hero Section -->
<section class="hero-section">
    <div class="container hero-content">
        <div class="hero-badge hero-anim-badge">
            <i class="fa-solid fa-crown"></i> Premier Luxury Ocean Charters in Sri Lanka
        </div>
        <h1 class="hero-title hero-anim-title">Luxury Ocean Safaris &amp; Coastal Voyages</h1>
        <p class="hero-subtitle hero-anim-subtitle">
            Experience Sri Lanka from the ocean —whale safaris, coastal sunsets, and tropical marine adventures in comfort and style.
        </p>
        <div class="hero-cta hero-anim-cta">
            <a href="${pageContext.request.contextPath}/experiences" class="btn btn-gold btn-lg">
                <i class="fa-solid fa-compass"></i> Discover Cruises
            </a>
            <a href="${pageContext.request.contextPath}/schedules" class="btn btn-outline-gold btn-lg">
                <i class="fa-regular fa-calendar-check"></i> Live Departures
            </a>
        </div>
        <div class="hero-anim-live" style="margin-top: 26px;">
            <div class="floating-ocean-badge">
                <span class="beacon-dot"></span>
                <i class="fa-solid fa-sailboat"></i>
                <span>6 Luxury Catamarans Under Sail &bull; Live Ocean Weather Optimal</span>
            </div>
        </div>
    </div>
</section>



<!-- Featured Safari Experiences -->
<section class="section">
    <div class="container">
        <div class="section-title-wrap scroll-reveal">
            <div class="section-eyebrow">Luxury Ocean Expeditions</div>
            <h2 class="section-title">Signature Safari Cruises</h2>
            <p class="section-desc">Handcrafted voyages along Sri Lanka's most celebrated coastal sanctuaries aboard purpose-built luxury catamarans.</p>
        </div>

        <div class="tour-grid">
            <c:forEach var="tour" items="${featuredTours}" varStatus="loop">
                <div class="tour-card scroll-reveal reveal-delay-${(loop.index % 3) + 1}">
                    <c:choose>
                        <%-- Tour-ID-specific images take priority over type-based --%>
                        <c:when test="${tour.id == 5}">
                            <%-- Bentota Mangrove Estuary & River Delta Cruise --%>
                            <c:set var="tourImg" value="${pageContext.request.contextPath}/assets/img/tours/bentota-mangrove-river.jpg" />
                        </c:when>
                        <c:when test="${tour.id == 6}">
                            <%-- Passikudah Coral Garden & Water Sports Cruise --%>
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1559128010-7c1ad6e1b6a5?q=80&w=800" />
                        </c:when>
                        <c:when test="${tour.id == 7}">
                            <%-- Kalpitiya Spinner Dolphin Super-Pod Safari --%>
                            <c:set var="tourImg" value="${pageContext.request.contextPath}/assets/img/tours/kalpitiya-dolphin-sail.jpg" />
                        </c:when>
                        <c:when test="${tour.id == 8}">
                            <%-- Tangalle Secluded Coves & Sunset Twilight Cruise --%>
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1532274402911-5a369e4c4bb5?q=80&w=800" />
                        </c:when>
                        <%-- Type-based fallbacks for any future tours --%>
                        <c:when test="${tour.tourType.name() == 'WHALE_WATCHING'}">
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1568430462989-44163eb1752f?q=80&w=800" />
                        </c:when>
                        <c:when test="${tour.tourType.name() == 'SUNSET_SAIL'}">
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=800" />
                        </c:when>
                        <c:when test="${tour.tourType.name() == 'SNORKELING_SAFARI'}">
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?q=80&w=800" />
                        </c:when>
                        <c:when test="${tour.tourType.name() == 'DINE_AT_SEA'}">
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1519690889869-e705e59f72e1?q=80&w=800" />
                        </c:when>
                        <c:when test="${tour.tourType.name() == 'DAYLIGHT_CRUISE'}">
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800" />
                        </c:when>
                        <c:when test="${tour.tourType.name() == 'OVERNIGHT_CHARTER'}">
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1586374579358-9d19d632b6df?q=80&w=800" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="tourImg" value="https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=800" />
                        </c:otherwise>
                    </c:choose>
                    <div class="tour-card-img" style="background-image: url('${tourImg}');">
                        <span class="tour-card-badge">${tour.tourType.title}</span>
                    </div>
                    <div class="tour-card-body">
                        <div class="tour-meta">
                            <span><i class="fa-regular fa-clock"></i> ${tour.durationHours} Hours</span>
                            <span><i class="fa-solid fa-users"></i> Max ${tour.maxPassengers} Pax</span>
                        </div>
                        <h3 class="tour-card-title">${tour.title}</h3>
                        <p class="tour-card-desc">${tour.description}</p>
                        <div class="tour-card-footer">
                            <div class="tour-price-box">
                                <span class="tour-price-label">Starting from</span>
                                <span class="tour-price-val">${tour.basePrice.formatted}</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/booking?tourId=${tour.id}" class="btn btn-gold btn-sm">
                                Book Cruise <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Luxury Fleet Showcase -->
<section class="section" style="background: #FFFFFF;">
    <div class="container">
        <div class="section-title-wrap scroll-reveal">
            <div class="section-eyebrow">Our Catamarans & Yachts</div>
            <h2 class="section-title">The Maritime Fleet</h2>
            <p class="section-desc">Maintained to rigorous SOLAS standards with dual-hull stability, sun trampolines, and shaded panoramic salons.</p>
        </div>

        <div class="fleet-grid">
            <c:forEach var="vessel" items="${fleet}" varStatus="loop">
                <div class="vessel-card scroll-reveal reveal-delay-${(loop.index % 4) + 1}">
                    <c:choose>
                        <%-- Assign image by registration number --%>
                        <c:when test="${vessel.registrationNo == 'SLC-CAT-001'}">
                            <%-- Ocean Pearl (Ceycat 55) – user-provided sailing catamaran photo --%>
                            <c:set var="vesselImg" value="${pageContext.request.contextPath}/assets/img/tours/ocean-pearl-ceycat.jpg" />
                        </c:when>
                        <c:when test="${vessel.registrationNo == 'SLC-CAT-002'}">
                            <%-- Sapphire Blue (Topaz 48) – user-provided aerial powerboat photo --%>
                            <c:set var="vesselImg" value="${pageContext.request.contextPath}/assets/img/tours/sapphire-blue-topaz.jpg" />
                        </c:when>
                        <c:when test="${vessel.registrationNo == 'SLC-YACHT-003'}">
                            <%-- Ceylon Monarch (Majesty 62) – user-provided sleek motor yacht photo --%>
                            <c:set var="vesselImg" value="${pageContext.request.contextPath}/assets/img/tours/ceylon-monarch-yacht.jpg" />
                        </c:when>
                        <c:when test="${vessel.registrationNo == 'SLC-SPD-004'}">
                            <%-- Wave Runner (SeaRay 32) – user-provided sunset speedboat photo --%>
                            <c:set var="vesselImg" value="${pageContext.request.contextPath}/assets/img/tours/wave-runner-searay.jpg" />
                        </c:when>
                        <c:when test="${vessel.registrationNo == 'SLC-CAT-005'}">
                            <%-- Mirissa Sun (Lagoon 42) – user-provided luxury catamaran photo --%>
                            <c:set var="vesselImg" value="${pageContext.request.contextPath}/assets/img/tours/mirissa-sun-catamaran.jpg" />
                        </c:when>
                        <c:when test="${vessel.registrationNo == 'SLC-CAT-006'}">
                            <%-- Indian Ocean Queen (Sunreef 60) – user-provided catamaran anchored photo --%>
                            <c:set var="vesselImg" value="${pageContext.request.contextPath}/assets/img/tours/indian-ocean-queen-cat.jpg" />
                        </c:when>
                        <c:when test="${vessel.registrationNo == 'SLC-SPD-007'}">
                            <%-- Southern Star Express (Axopar 37) – performance speedboat --%>
                            <c:set var="vesselImg" value="https://images.unsplash.com/photo-1605281317010-fe5ffe798166?q=80&w=800" />
                        </c:when>
                        <c:when test="${vessel.registrationNo == 'SLC-YACHT-008'}">
                            <%-- Serendib Explorer (Princess 55) – user-provided flybridge yacht photo --%>
                            <c:set var="vesselImg" value="${pageContext.request.contextPath}/assets/img/tours/serendib-explorer-yacht.jpg" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="vesselImg" value="https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=800" />
                        </c:otherwise>
                    </c:choose>
                    <div class="vessel-card-img" style="background-image: url('${vesselImg}');"></div>
                    <div class="vessel-card-body">
                        <div class="vessel-reg-badge">${vessel.registrationNo}</div>
                        <h3 style="font-size: 17px; color: var(--navy-primary); margin-bottom: 8px;">${vessel.name}</h3>
                        <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 16px; line-height: 1.55;">
                            ${vessel.vesselArchitecture}
                        </p>
                        <div style="display: flex; justify-content: center; gap: 8px; margin-bottom: 16px;">
                            <span class="badge badge-primary"><i class="fa-solid fa-users"></i> ${vessel.capacity.maxPassengers} Guests</span>
                            <span class="badge ${vessel.statusBadgeClass}">${vessel.statusLabel}</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/booking" class="btn btn-outline-navy btn-sm" style="width: 100%;">
                            Charter Vessel
                        </a>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Why Sail Lanka Features -->
<section class="section" style="background: var(--bg-main);">
    <div class="container">
        <div class="section-title-wrap scroll-reveal">
            <div class="section-eyebrow">The Sail Lanka Distinction</div>
            <h2 class="section-title">Why Sail With Us</h2>
        </div>

        <div class="feature-box">
            <div class="feature-item scroll-reveal reveal-delay-1">
                <i class="fa-solid fa-shield-halved" style="font-size: 32px; color: var(--marine-blue);"></i>
                <h3>Uncompromising Safety</h3>
                <p style="font-size: 14px; color: var(--text-muted);">
                    All catamarans equipped with certified SOLAS life rafts, satellite EPIRBs, life jackets, and captained by Master Mariners with decades of ocean experience.
                </p>
            </div>
            <div class="feature-item scroll-reveal reveal-delay-2">
                <i class="fa-solid fa-utensils" style="font-size: 32px; color: var(--champagne-gold);"></i>
                <h3>Gourmet Dining at Sea</h3>
                <p style="font-size: 14px; color: var(--text-muted);">
                    Enjoy fresh tropical fruit platters, Ceylon tea, artisanal canapés, and fresh seafood catches prepared on board with premium beverages.
                </p>
            </div>
            <div class="feature-item scroll-reveal reveal-delay-3">
                <i class="fa-solid fa-binoculars" style="font-size: 32px; color: var(--ocean-teal);"></i>
                <h3>Marine Naturalist Guides</h3>
                <p style="font-size: 14px; color: var(--text-muted);">
                    Learn from resident marine biologists who provide ethical whale watching commentary, identify individual blue whales, and ensure zero harassment to ocean life.
                </p>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
