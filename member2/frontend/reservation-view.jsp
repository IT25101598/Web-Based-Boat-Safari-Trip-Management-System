<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Reservation ${reservation.bookingRef} | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0;">Reservation #${reservation.bookingRef}</h1>
        </div>
        <a href="${pageContext.request.contextPath}/reservations" class="btn btn-outline-gold btn-sm">
            &larr; Back to Reservations Desk
        </a>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 820px;">
        <div class="card">
            <div class="card-header">
                <div>
                    <h3 style="font-size: 18px; margin: 0;">Reservation & Manifest Details</h3>
                </div>
                <span class="badge ${reservation.statusBadgeClass}">${reservation.statusLabel}</span>
            </div>
            <div class="card-body">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px;">
                    <div>
                        <span style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Tour Title</span>
                        <div style="font-weight: 700; color: var(--navy-primary); font-size: 16px;">${reservation.tourTitle}</div>
                    </div>
                    <div>
                        <span style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Customer</span>
                        <div style="font-weight: 700;">${reservation.customerName} (${reservation.customerEmail})</div>
                    </div>
                    <div>
                        <span style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Booking Reference</span>
                        <div style="font-weight: 700; color: var(--marine-blue);">${reservation.bookingRef}</div>
                    </div>
                    <div>
                        <span style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Total Paid / Payable</span>
                        <div style="font-weight: 700; font-size: 18px; color: var(--navy-primary);">${reservation.finalAmount.formatted}</div>
                    </div>
                </div>

                <c:if test="${not empty reservation.specialNotes}">
                    <div style="background: #FFFBEB; border: 1px solid #FDE68A; padding: 12px 16px; border-radius: 6px; margin-bottom: 24px; font-size: 13.5px;">
                        <strong><i class="fa-solid fa-note-sticky" style="color: #D97706;"></i> Special Notes:</strong> ${reservation.specialNotes}
                    </div>
                </c:if>

                <h4 style="font-size: 16px; color: var(--navy-primary); margin-bottom: 12px;"><i class="fa-solid fa-users"></i> Registered Passenger Manifest</h4>
                <div class="table-responsive">
                    <table class="data-table" style="font-size: 13px;">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Full Name</th>
                                <th>ID / Passport</th>
                                <th>Age</th>
                                <th>Gender</th>
                                <th>Nationality</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${reservation.passengers}" varStatus="status">
                                <tr>
                                    <td>${status.index + 1}</td>
                                    <td><strong>${p.fullName}</strong></td>
                                    <td>${p.idOrPassport}</td>
                                    <td>${p.age}</td>
                                    <td>${p.gender}</td>
                                    <td>${p.nationality}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 30px;">
                    <a href="${pageContext.request.contextPath}/booking/confirmation?ref=${reservation.bookingRef}" class="btn btn-outline-navy btn-sm">
                        <i class="fa-solid fa-ticket"></i> View Boarding Pass
                    </a>
                    <c:if test="${reservation.status.name() != 'CANCELLED'}">
                        <div style="display: flex; gap: 10px;">
                            <a href="${pageContext.request.contextPath}/reservations/edit?id=${reservation.id}" class="btn btn-outline-gold btn-sm">
                                <i class="fa-solid fa-pen-to-square"></i> Modify Details
                            </a>
                            <form action="${pageContext.request.contextPath}/reservations/cancel" method="POST" onsubmit="return confirm('Cancel reservation and initiate refund?');">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="id" value="${reservation.id}">
                                <button type="submit" class="btn btn-danger btn-sm">
                                    <i class="fa-solid fa-xmark"></i> Cancel Booking
                                </button>
                            </form>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
