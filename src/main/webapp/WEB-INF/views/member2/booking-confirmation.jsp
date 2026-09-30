<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Booking Ticket ${reservation.bookingRef} | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 130px 0 40px 0; color: #FFFFFF; text-align: center;">
    <div class="container">
        <div style="width: 56px; height: 56px; background: var(--success); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px auto; font-size: 24px; color: #FFFFFF;">
            <i class="fa-solid fa-check"></i>
        </div>
        <h1 style="font-size: 34px; color: #FFFFFF; margin-bottom: 8px;">Booking Confirmed!</h1>
        <p style="color: #94A3B8;">Your luxury boat safari boarding ticket has been issued.</p>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 780px;">
        <div class="card" style="border: 2px solid var(--border-gold); box-shadow: var(--shadow-lg);">
            <!-- Ticket Header -->
            <div class="card-header" style="background: linear-gradient(135deg, var(--navy-primary), var(--navy-secondary)); color: #FFFFFF; padding: 24px;">
                <div>
                    <div style="font-size: 11px; text-transform: uppercase; letter-spacing: 2px; color: var(--champagne-gold);">Official Boarding Pass</div>
                    <div style="font-size: 24px; font-weight: 800; color: #FFFFFF; letter-spacing: 1px;">${reservation.bookingRef}</div>
                </div>
                <div style="text-align: right;">
                    <span class="badge ${reservation.statusBadgeClass}" style="font-size: 13px; padding: 6px 14px;">${reservation.statusLabel}</span>
                </div>
            </div>

            <div class="card-body" style="padding: 30px;">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px;">
                    <div>
                        <div style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Tour Safari</div>
                        <div style="font-size: 16px; font-weight: 700; color: var(--navy-primary);">${reservation.tourTitle}</div>
                    </div>
                    <div>
                        <div style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Departure Time</div>
                        <div style="font-size: 16px; font-weight: 700; color: var(--navy-primary);">
                            ${reservation.schedule != null ? reservation.schedule.formattedDeparture : 'Scheduled'}
                        </div>
                    </div>
                    <div>
                        <div style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Primary Guest</div>
                        <div style="font-size: 15px; font-weight: 600;">${reservation.customerName}</div>
                    </div>
                    <div>
                        <div style="font-size: 12px; color: var(--text-light); text-transform: uppercase;">Passenger Count</div>
                        <div style="font-size: 15px; font-weight: 600;">${reservation.passengerCount} Passengers</div>
                    </div>
                </div>

                <hr style="border: none; border-top: 1px solid var(--border-color); margin: 20px 0;">

                <h4 style="font-size: 16px; color: var(--navy-primary); margin-bottom: 12px;"><i class="fa-solid fa-users"></i> Passenger Manifest</h4>
                <div class="table-responsive" style="margin-bottom: 24px;">
                    <table class="data-table" style="font-size: 13px;">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Full Name</th>
                                <th>Passport / NIC</th>
                                <th>Age</th>
                                <th>Gender</th>
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
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Financial Breakdown -->
                <div style="background: #F8FAFD; border-radius: 8px; padding: 16px; font-size: 14px;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                        <span>Gross Fare:</span>
                        <span>${reservation.totalAmount.formatted}</span>
                    </div>
                    <c:if test="${reservation.discountAmount.amount > 0}">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 6px; color: var(--success);">
                            <span>Discount (${reservation.promoCode != null ? reservation.promoCode : 'Promo'}):</span>
                            <span>-${reservation.discountAmount.formatted}</span>
                        </div>
                    </c:if>
                    <div style="display: flex; justify-content: space-between; font-size: 18px; font-weight: 800; color: var(--navy-primary); border-top: 1px solid #E2E8F0; padding-top: 8px; margin-top: 8px;">
                        <span>Total Paid / Payable:</span>
                        <span>${reservation.finalAmount.formatted}</span>
                    </div>
                </div>

                <div style="margin-top: 28px; display: flex; justify-content: space-between; align-items: center;">
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-navy btn-sm">
                        <i class="fa-solid fa-house"></i> Return Home
                    </a>
                    <button onclick="window.print()" class="btn btn-gold btn-sm">
                        <i class="fa-solid fa-print"></i> Print Boarding Ticket
                    </button>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
