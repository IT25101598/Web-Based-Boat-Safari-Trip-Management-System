<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Safari Experiences & Tour Packages | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<style>
/* Scoped styles ensuring perfect card layout on Experiences page */
.experiences-hero {
    background: linear-gradient(135deg, rgba(7, 24, 44, 0.94) 0%, rgba(11, 37, 69, 0.92) 100%), 
                url('https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1600') center/cover no-repeat;
    padding: 140px 0 60px 0;
    color: #FFFFFF;
    text-align: center;
    border-bottom: 1px solid rgba(212, 175, 55, 0.25);
    position: relative;
}

.experiences-hero .hero-subtitle {
    color: var(--champagne-gold, #D4AF37);
    font-weight: 700;
    text-transform: uppercase;
    font-size: 13px;
    letter-spacing: 2px;
    margin-bottom: 10px;
    display: inline-block;
}

.experiences-hero h1 {
    font-size: 42px;
    color: #FFFFFF;
    margin-bottom: 14px;
    font-family: var(--font-heading, 'Outfit', sans-serif);
    font-weight: 800;
}

.experiences-hero p {
    max-width: 650px;
    margin: 0 auto;
    color: #CBD5E1;
    font-size: 16px;
    line-height: 1.6;
}

.experiences-section {
    padding: 60px 0 100px 0;
    background-color: var(--bg-main, #F4F7FB);
}

.tour-grid {
    display: grid !important;
    grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)) !important;
    gap: 32px !important;
    align-items: stretch;
}

@media (max-width: 768px) {
    .tour-grid {
        grid-template-columns: 1fr !important;
        gap: 24px !important;
    }
    .experiences-hero h1 {
        font-size: 32px;
    }
}

.tour-card {
    background: #FFFFFF !important;
    border-radius: 14px !important;
    overflow: hidden !important;
    box-shadow: 0 4px 20px rgba(11, 37, 69, 0.08) !important;
    border: 1px solid #E2E8F0 !important;
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.3s cubic-bezier(0.4, 0, 0.2, 1), border-color 0.3s ease !important;
    display: flex !important;
    flex-direction: column !important;
    height: 100% !important;
}

.tour-card:hover {
    transform: translateY(-6px) !important;
    box-shadow: 0 18px 40px rgba(11, 37, 69, 0.14) !important;
    border-color: rgba(212, 175, 55, 0.5) !important;
}

.tour-card-img-wrap,
.tour-card-img {
    position: relative !important;
    width: 100% !important;
    height: 240px !important;
    min-height: 240px !important;
    max-height: 240px !important;
    overflow: hidden !important;
    background: #0B2545 !important;
    flex-shrink: 0 !important;
    display: block !important;
}

.tour-card-img-tag {
    width: 100% !important;
    height: 100% !important;
    object-fit: cover !important;
    object-position: center !important;
    display: block !important;
    transition: transform 0.5s cubic-bezier(0.25, 1, 0.5, 1) !important;
}

.tour-card:hover .tour-card-img-tag {
    transform: scale(1.06) !important;
}

.tour-card-badge {
    position: absolute !important;
    top: 16px !important;
    left: 16px !important;
    background: rgba(7, 24, 44, 0.88) !important;
    backdrop-filter: blur(8px) !important;
    -webkit-backdrop-filter: blur(8px) !important;
    color: #D4AF37 !important;
    padding: 6px 14px !important;
    border-radius: 9999px !important;
    font-size: 11.5px !important;
    font-weight: 700 !important;
    letter-spacing: 0.5px !important;
    text-transform: uppercase !important;
    border: 1px solid rgba(212, 175, 55, 0.4) !important;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25) !important;
    z-index: 3 !important;
    pointer-events: none !important;
    display: inline-block !important;
    line-height: normal !important;
}

.tour-card-body {
    padding: 24px !important;
    display: flex !important;
    flex-direction: column !important;
    flex-grow: 1 !important;
    background: #FFFFFF !important;
}

.tour-meta {
    display: flex !important;
    flex-wrap: wrap !important;
    align-items: center !important;
    gap: 16px !important;
    margin-bottom: 12px !important;
    font-size: 13px !important;
    font-weight: 600 !important;
    color: #64748B !important;
}

.tour-meta span {
    display: inline-flex !important;
    align-items: center !important;
    gap: 6px !important;
}

.tour-meta i {
    color: #0077B6 !important;
    font-size: 14px !important;
}

.tour-card-title {
    font-size: 20px !important;
    font-weight: 700 !important;
    color: #0B2545 !important;
    margin-bottom: 10px !important;
    line-height: 1.35 !important;
    letter-spacing: -0.2px !important;
}

.tour-card-desc {
    font-size: 14px !important;
    color: #64748B !important;
    line-height: 1.65 !important;
    margin-bottom: 18px !important;
    flex-grow: 1 !important;
    display: -webkit-box !important;
    -webkit-line-clamp: 3 !important;
    -webkit-box-orient: vertical !important;
    overflow: hidden !important;
}

.tour-inclusions-box {
    margin-bottom: 20px !important;
    font-size: 12.5px !important;
    line-height: 1.55 !important;
    color: #475569 !important;
    background: #F8FAFC !important;
    padding: 12px 14px !important;
    border-radius: 8px !important;
    border-left: 3px solid #028090 !important;
}

.tour-inclusions-box strong {
    color: #0B2545 !important;
    display: block !important;
    margin-bottom: 4px !important;
    font-size: 12.5px !important;
}

.tour-inclusions-box strong i {
    color: #028090 !important;
    margin-right: 4px !important;
}

.tour-card-footer {
    display: flex !important;
    align-items: center !important;
    justify-content: space-between !important;
    padding-top: 18px !important;
    border-top: 1px solid #E2E8F0 !important;
    margin-top: auto !important;
    gap: 12px !important;
}

.tour-price-box {
    display: flex !important;
    flex-direction: column !important;
}

.tour-price-label {
    font-size: 11px !important;
    text-transform: uppercase !important;
    letter-spacing: 0.5px !important;
    color: #94A3B8 !important;
    font-weight: 600 !important;
}

.tour-price-val {
    font-size: 21px !important;
    font-weight: 800 !important;
    color: #0B2545 !important;
    font-family: var(--font-heading, 'Outfit', sans-serif) !important;
    line-height: 1.2 !important;
    margin-top: 2px !important;
}
</style>

<div class="experiences-hero">
    <div class="container">
        <span class="hero-subtitle">Ocean Adventures & Private Charters</span>
        <h1>Safari Experiences</h1>
        <p>
            Select from our luxury blue whale safaris, scenic coastal sunset sails, or private dining cruises along Sri Lanka's turquoise waters.
        </p>
    </div>
</div>

<section class="experiences-section">
    <div class="container">
        <div class="tour-grid">
            <c:forEach var="tour" items="${tours}">
                <%-- Assign high quality, topic-tailored marine photography --%>
                <c:choose>
                    <c:when test="${tour.id == 1}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=800" />
                    </c:when>
                    <c:when test="${tour.id == 2}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800" />
                    </c:when>
                    <c:when test="${tour.id == 3}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1582967788606-a171c1080cb0?q=80&w=800" />
                    </c:when>
                    <c:when test="${tour.id == 4}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?q=80&w=800" />
                    </c:when>
                    <c:when test="${tour.id == 5}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800" />
                    </c:when>
                    <c:when test="${tour.id == 6}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?q=80&w=800" />
                    </c:when>
                    <c:when test="${tour.id == 7}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1570481662006-a3a1374699e8?q=80&w=800" />
                    </c:when>
                    <c:when test="${tour.id == 8}">
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=800" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="tourImg" value="https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=800" />
                    </c:otherwise>
                </c:choose>

                <div class="tour-card">
                    <div class="tour-card-img-wrap tour-card-img">
                        <img src="${tourImg}" alt="${tour.title}" class="tour-card-img-tag" loading="lazy" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=800';" />
                        <span class="tour-card-badge">${tour.tourType.title}</span>
                    </div>
                    <div class="tour-card-body">
                        <div class="tour-meta">
                            <span><i class="fa-regular fa-clock"></i> ${tour.durationHours} Hours</span>
                            <span><i class="fa-solid fa-users"></i> Max ${tour.maxPassengers} Pax</span>
                        </div>
                        <h3 class="tour-card-title">${tour.title}</h3>
                        <p class="tour-card-desc">${tour.description}</p>
                        
                        <c:if test="${not empty tour.inclusions}">
                            <div class="tour-inclusions-box">
                                <strong><i class="fa-solid fa-check-circle"></i> Inclusions:</strong>
                                <span>${tour.inclusions}</span>
                            </div>
                        </c:if>

                        <div class="tour-card-footer">
                            <div class="tour-price-box">
                                <span class="tour-price-label">Price per person</span>
                                <span class="tour-price-val">${tour.basePrice.formatted}</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/booking?tourId=${tour.id}" class="btn btn-gold btn-sm">
                                Book Now <i class="fa-solid fa-calendar-check"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
