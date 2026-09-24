<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${tour.title} | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 130px 0 50px 0; color: #FFFFFF;">
    <div class="container">
        <span class="badge badge-gold" style="margin-bottom: 12px;">${tour.tourType.title}</span>
        <h1 style="font-size: 38px; color: #FFFFFF; margin-bottom: 12px;">${tour.title}</h1>
        <div style="display: flex; gap: 24px; color: #CBD5E1; font-size: 15px;">
            <span><i class="fa-regular fa-clock"></i> ${tour.durationHours} Hours Duration</span>
            <span><i class="fa-solid fa-users"></i> Up to ${tour.maxPassengers} Guests</span>
            <span><i class="fa-solid fa-tag"></i> <strong>${tour.basePrice.formatted}</strong> per guest</span>
        </div>
    </div>
</div>

<section class="section" style="padding: 50px 0;">
    <div class="container" style="display: grid; grid-template-columns: 2fr 1fr; gap: 40px;">
        <div>
            <div class="card" style="margin-bottom: 30px;">
                <div class="card-body">
                    <h2 style="font-size: 22px; color: var(--navy-primary); margin-bottom: 16px;">Voyage Overview</h2>
                    <p style="font-size: 15px; line-height: 1.8; color: var(--text-main); margin-bottom: 24px;">
                        ${tour.description}
                    </p>

                    <c:if test="${not empty tour.inclusions}">
                        <h3 style="font-size: 18px; color: var(--navy-primary); margin-bottom: 12px;"><i class="fa-solid fa-circle-check" style="color: var(--success);"></i> Included In Experience</h3>
                        <p style="font-size: 14.5px; color: var(--text-muted); margin-bottom: 20px;">${tour.inclusions}</p>
                    </c:if>

                    <c:if test="${not empty tour.exclusions}">
                        <h3 style="font-size: 18px; color: var(--navy-primary); margin-bottom: 12px;"><i class="fa-solid fa-circle-xmark" style="color: var(--danger);"></i> Excluded</h3>
                        <p style="font-size: 14.5px; color: var(--text-muted);">${tour.exclusions}</p>
                    </c:if>

                    <c:if test="${not empty tour.specialInstructions}">
                        <div style="background: rgba(200, 169, 106, 0.12); border-left: 4px solid var(--champagne-gold); padding: 14px 18px; border-radius: 6px; margin-top: 20px;">
                            <h4 style="margin: 0 0 6px 0; color: var(--navy-primary); font-size: 15px; font-weight: 700;">
                                <i class="fa-solid fa-circle-info" style="color: var(--champagne-gold);"></i> Special Instructions & Guest Advisory
                            </h4>
                            <p style="margin: 0; font-size: 14px; color: var(--navy-dark); line-height: 1.6;">${tour.specialInstructions}</p>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Available Scheduled Departures -->
            <div class="card">
                <div class="card-header">
                    <h3 style="font-size: 18px; margin: 0;"><i class="fa-regular fa-calendar-check"></i> Upcoming Departures</h3>
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Departure Time</th>
                                <th>Seats Available</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${schedules}">
                                <tr>
                                    <td><strong>${s.formattedDeparture}</strong></td>
                                    <td><span class="badge badge-primary">${s.availableSeats} seats left</span></td>
                                    <td><span class="badge ${s.statusBadgeClass}">${s.statusLabel}</span></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/booking?tourId=${tour.id}&scheduleId=${s.id}" class="btn btn-gold btn-sm">
                                            Book Seats <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty schedules}">
                                <tr>
                                    <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 24px;">
                                        No upcoming departures scheduled for this tour right now.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div>
            <div class="card" style="border: 2px solid var(--border-gold); position: sticky; top: 100px;">
                <div class="card-body" style="text-align: center; padding: 32px 24px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-light); text-transform: uppercase;">Standard Rate</div>
                    <div style="font-size: 36px; font-weight: 800; color: var(--navy-primary); margin: 6px 0 16px 0;">
                        ${tour.basePrice.formatted}
                    </div>
                    <p style="font-size: 13.5px; color: var(--text-muted); margin-bottom: 24px;">
                        Includes luxury catamaran cruise, safety equipment, fresh gourmet food & beverage, and wildlife naturalist guide.
                    </p>
                    <a href="${pageContext.request.contextPath}/booking?tourId=${tour.id}" class="btn btn-gold btn-lg" style="width: 100%; margin-bottom: 12px;">
                        <i class="fa-solid fa-ticket"></i> Proceed to Booking
                    </a>
                    <a href="${pageContext.request.contextPath}/experiences" class="btn btn-outline-navy btn-sm" style="width: 100%;">
                        &larr; Browse All Tours
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
