<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Destinations & Harbours | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 130px 0 50px 0; color: #FFFFFF; text-align: center;">
    <div class="container">
        <div style="color: var(--champagne-gold); font-weight: 700; text-transform: uppercase; font-size: 13px; letter-spacing: 2px; margin-bottom: 8px;">
            Sri Lankan Coastal Sanctuaries
        </div>
        <h1 style="font-size: 42px; color: #FFFFFF; margin-bottom: 12px;">Ports & Sailing Destinations</h1>
        <p style="max-width: 600px; margin: 0 auto; color: #94A3B8;">
            From the continental shelf of Mirissa to the historic ramparts of Galle and the coral gardens of Pigeon Island.
        </p>
    </div>
</div>

<style>
.dest-card-img {
    height: 200px;
    background-size: cover;
    background-position: center;
    position: relative;
    overflow: hidden;
}
.dest-card-img::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(to top, rgba(11,37,69,0.55) 0%, transparent 60%);
}
.dest-card-img .dest-badge {
    position: absolute;
    top: 12px;
    left: 12px;
    z-index: 2;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    background: rgba(212,175,55,0.92);
    color: #0B2545;
    padding: 4px 10px;
    border-radius: 20px;
}
</style>

<section class="section">
    <div class="container">
        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 30px;">
            <c:forEach var="dest" items="${destinations}">
                <div class="card" style="overflow:hidden;">
                    <c:choose>
                        <c:when test="${dest.harborName == 'Mirissa Fishery Harbour'}">
                            <%-- Mirissa Coconut Hill – user-provided real location photo --%>
                            <c:set var="destImg" value="${pageContext.request.contextPath}/assets/img/tours/mirissa-bay-coconut-hill.jpg" />
                        </c:when>
                        <c:when test="${dest.harborName == 'Galle International Harbour'}">
                            <%-- Galle Fort – user-provided real Sri Lanka heritage photo --%>
                            <c:set var="destImg" value="${pageContext.request.contextPath}/assets/img/tours/galle-fort-heritage.jpg" />
                        </c:when>
                        <c:when test="${dest.harborName == 'Trincomalee Cod Bay Pier'}">
                            <%-- Trincomalee – Pigeon Island coral reef --%>
                            <c:set var="destImg" value="https://images.unsplash.com/photo-1559128010-7c1ad6e1b6a5?q=80&w=800" />
                        </c:when>
                        <c:when test="${dest.harborName == 'Bentota River Marina'}">
                            <%-- Bentota – user-provided aerial lagoon photo --%>
                            <c:set var="destImg" value="${pageContext.request.contextPath}/assets/img/tours/bentota-lagoon-aerial.jpg" />
                        </c:when>
                        <c:when test="${dest.harborName == 'Passikudah Outer Pier'}">
                            <%-- Passikudah – user-provided real aerial coral bay photo --%>
                            <c:set var="destImg" value="${pageContext.request.contextPath}/assets/img/tours/passikudah-coral-bay.jpg" />
                        </c:when>
                        <c:when test="${dest.harborName == 'Kalpitiya Fishery Harbour'}">
                            <%-- Kalpitiya – user-provided real lagoon/palm photo --%>
                            <c:set var="destImg" value="${pageContext.request.contextPath}/assets/img/tours/kalpitiya-lagoon.jpg" />
                        </c:when>
                        <c:when test="${dest.harborName == 'Kurikadduwan Jetty'}">
                            <%-- Jaffna / Delft Island – user-provided real northern coast photo --%>
                            <c:set var="destImg" value="${pageContext.request.contextPath}/assets/img/tours/jaffna-delft-coast.jpg" />
                        </c:when>
                        <c:when test="${dest.harborName == 'Tangalle Natural Harbour'}">
                            <%-- Tangalle – user-provided real Sri Lanka beach photo --%>
                            <c:set var="destImg" value="${pageContext.request.contextPath}/assets/img/tours/tangalle-beach.jpg" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="destImg" value="https://images.unsplash.com/photo-1544551763-77ef2d0cfc6c?q=80&w=800" />
                        </c:otherwise>
                    </c:choose>
                    <div class="dest-card-img" style="background-image: url('${destImg}');">
                        <span class="dest-badge">${dest.region.displayName}</span>
                    </div>
                    <div class="card-body">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <span style="font-size: 12px; color: var(--text-light);"><i class="fa-solid fa-compass"></i> Port</span>
                        </div>
                        <h3 style="font-size: 20px; color: var(--navy-primary); margin-bottom: 6px;">${dest.name}</h3>
                        <div style="font-size: 13.5px; font-weight: 600; color: var(--marine-blue); margin-bottom: 12px;">
                            <i class="fa-solid fa-location-dot"></i> ${dest.harborName}
                        </div>
                        <p style="font-size: 14px; color: var(--text-muted); margin-bottom: 20px;">
                            ${dest.description}
                        </p>
                        <a href="${pageContext.request.contextPath}/experiences" class="btn btn-outline-navy btn-sm" style="width: 100%;">
                            View Departing Tours
                        </a>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
