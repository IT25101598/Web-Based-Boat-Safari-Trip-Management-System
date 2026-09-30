<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Reservation Management | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Reservation Desk & Bookings</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Real-time boat bookings, passenger manifest verification, and ticket control.</p>
        </div>
        <a href="${pageContext.request.contextPath}/booking" class="btn btn-gold btn-sm">
            <i class="fa-solid fa-plus"></i> New Reservation
        </a>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <!-- Search Bar -->
        <form action="${pageContext.request.contextPath}/reservations" method="GET" style="margin-bottom: 24px; display: flex; gap: 12px; max-width: 480px;">
            <input type="text" name="search" value="${search}" class="form-control" placeholder="Search by Booking Ref, Guest, or Tour...">
            <button type="submit" class="btn btn-primary"><i class="fa-solid fa-search"></i></button>
            <c:if test="${not empty search}">
                <a href="${pageContext.request.contextPath}/reservations" class="btn btn-outline-navy">Clear</a>
            </c:if>
        </form>

        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Booking Ref</th>
                            <th>Guest Name</th>
                            <th>Tour Title</th>
                            <th>Passengers</th>
                            <th>Gross Total</th>
                            <th>Discount</th>
                            <th>Final Fare</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${reservations}">
                            <tr>
                                <td>
                                    <strong style="color: var(--marine-blue);">
                                        <a href="${pageContext.request.contextPath}/reservations/view?ref=${r.bookingRef}">${r.bookingRef}</a>
                                    </strong>
                                </td>
                                <td>${r.customerName}</td>
                                <td>${r.tourTitle}</td>
                                <td><span class="badge badge-primary">${r.passengerCount} Guests</span></td>
                                <td>${r.totalAmount.formatted}</td>
                                <td><span style="color: var(--success);">${r.discountAmount.formatted}</span></td>
                                <td><strong>${r.finalAmount.formatted}</strong></td>
                                <td><span class="badge ${r.statusBadgeClass}">${r.statusLabel}</span></td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/reservations/view?ref=${r.bookingRef}" class="btn btn-outline-navy btn-sm" title="View Ticket">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                        <c:if test="${r.status.name() != 'CANCELLED'}">
                                            <form action="${pageContext.request.contextPath}/reservations/cancel" method="POST" onsubmit="return confirm('Cancel this booking and release seats?');" style="display: inline;">
                                                <input type="hidden" name="csrf_token" value="${csrfToken}">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <button type="submit" class="btn btn-danger btn-sm" title="Cancel Booking">
                                                    <i class="fa-solid fa-xmark"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
