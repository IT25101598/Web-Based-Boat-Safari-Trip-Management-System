<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="My Bookings | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container">
        <h1 style="font-size: 32px; color: #FFFFFF;">My Ocean Cruise Bookings</h1>
        <p style="color: #94A3B8;">View your booked safari tickets, departure timings, and manifests.</p>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <c:choose>
            <c:when test="${not empty bookings}">
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 24px;">
                    <c:forEach var="b" items="${bookings}">
                        <div class="card">
                            <div class="card-header">
                                <span style="font-weight: 700; color: var(--marine-blue);">${b.bookingRef}</span>
                                <span class="badge ${b.statusBadgeClass}">${b.statusLabel}</span>
                            </div>
                            <div class="card-body">
                                <h3 style="font-size: 18px; color: var(--navy-primary); margin-bottom: 8px;">${b.tourTitle}</h3>
                                <p style="font-size: 13.5px; color: var(--text-muted); margin-bottom: 16px;">
                                    <i class="fa-solid fa-users"></i> ${b.passengerCount} Passengers registered
                                </p>
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <span style="font-size: 18px; font-weight: 800; color: var(--navy-primary);">${b.finalAmount.formatted}</span>
                                    <a href="${pageContext.request.contextPath}/booking/confirmation?ref=${b.bookingRef}" class="btn btn-gold btn-sm">
                                        <i class="fa-solid fa-ticket"></i> View Ticket
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card" style="text-align: center; padding: 60px 20px;">
                    <i class="fa-solid fa-sailboat" style="font-size: 48px; color: var(--text-light); margin-bottom: 16px;"></i>
                    <h3 style="color: var(--navy-primary); margin-bottom: 8px;">No Bookings Found</h3>
                    <p style="color: var(--text-muted); margin-bottom: 24px;">You haven't reserved any luxury ocean safaris yet.</p>
                    <div>
                        <a href="${pageContext.request.contextPath}/experiences" class="btn btn-gold">Explore Cruises</a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
