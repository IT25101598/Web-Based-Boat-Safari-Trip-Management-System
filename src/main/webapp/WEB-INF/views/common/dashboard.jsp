<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Back-Office Operations Dashboard | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <div style="color: var(--champagne-gold); font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px;">
                Operations & Management Center
            </div>
            <h1 style="font-size: 32px; color: #FFFFFF; margin-top: 4px;">Maritime Back-Office Dashboard</h1>
            <p style="color: #94A3B8; font-size: 14px;">Logged in as: <strong>${currentUser.fullName}</strong> (${currentUser.role.displayName})</p>
        </div>
        <div style="display: flex; gap: 12px;">
            <a href="${pageContext.request.contextPath}/admin/emergency/create" class="btn btn-danger btn-sm">
                <i class="fa-solid fa-triangle-exclamation"></i> Issue Safety Alert
            </a>
            <a href="${pageContext.request.contextPath}/admin/schedules/create" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-calendar-plus"></i> Schedule Departure
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <!-- Operations Metric KPI Cards -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 20px; margin-bottom: 35px;">
            <!-- Tours -->
            <div class="card" style="border-left: 4px solid var(--navy-primary);">
                <div class="card-body" style="padding: 20px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-light); text-transform: uppercase;">Tours</div>
                    <div style="font-size: 28px; font-weight: 800; color: var(--navy-primary); margin: 6px 0;">${totalTours}</div>
                    <a href="${pageContext.request.contextPath}/admin/tours" style="font-size: 13px; font-weight: 600;">Manage Tours &rarr;</a>
                </div>
            </div>

            <!-- Bookings -->
            <div class="card" style="border-left: 4px solid var(--marine-blue);">
                <div class="card-body" style="padding: 20px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-light); text-transform: uppercase;">Bookings</div>
                    <div style="font-size: 28px; font-weight: 800; color: var(--marine-blue); margin: 6px 0;">${totalReservations}</div>
                    <a href="${pageContext.request.contextPath}/reservations" style="font-size: 13px; font-weight: 600;">View Bookings &rarr;</a>
                </div>
            </div>

            <!-- Fleet -->
            <div class="card" style="border-left: 4px solid var(--ocean-teal);">
                <div class="card-body" style="padding: 20px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-light); text-transform: uppercase;">Fleet</div>
                    <div style="font-size: 28px; font-weight: 800; color: var(--ocean-teal); margin: 6px 0;">${totalVessels}</div>
                    <a href="${pageContext.request.contextPath}/admin/boats" style="font-size: 13px; font-weight: 600;">Manage Vessels &rarr;</a>
                </div>
            </div>

            <!-- Maintenance -->
            <div class="card" style="border-left: 4px solid #D97706;">
                <div class="card-body" style="padding: 20px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-light); text-transform: uppercase;">Maintenance</div>
                    <div style="font-size: 20px; font-weight: 800; color: #D97706; margin: 10px 0 6px 0;">LKR ${totalMaintenanceCost}</div>
                    <a href="${pageContext.request.contextPath}/admin/maintenance" style="font-size: 13px; font-weight: 600;">Maintenance Log &rarr;</a>
                </div>
            </div>

            <!-- Safety Alerts -->
            <div class="card" style="border-left: 4px solid var(--danger);">
                <div class="card-body" style="padding: 20px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-light); text-transform: uppercase;">Safety Alerts</div>
                    <div style="font-size: 28px; font-weight: 800; color: var(--danger); margin: 6px 0;">${activeEmergencies}</div>
                    <a href="${pageContext.request.contextPath}/admin/emergency" style="font-size: 13px; font-weight: 600;">Safety Notices &rarr;</a>
                </div>
            </div>

            <!-- Promotions -->
            <div class="card" style="border-left: 4px solid var(--champagne-gold);">
                <div class="card-body" style="padding: 20px;">
                    <div style="font-size: 12px; font-weight: 700; color: var(--text-light); text-transform: uppercase;">Promotions</div>
                    <div style="font-size: 28px; font-weight: 800; color: var(--champagne-gold); margin: 6px 0;">${activePromotions}</div>
                    <a href="${pageContext.request.contextPath}/admin/promotions" style="font-size: 13px; font-weight: 600;">Campaigns &rarr;</a>
                </div>
            </div>
        </div>

        <!-- Navigation Bar to Operations Consoles -->
        <div class="card" style="margin-bottom: 35px; background: #FFFFFF; border: 1px solid var(--border-gold);">
            <div class="card-body" style="padding: 18px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <span style="font-weight: 700; color: var(--navy-primary); font-size: 14px;"><i class="fa-solid fa-cubes"></i> Operations Navigation:</span>
                <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                    <a href="${pageContext.request.contextPath}/admin/tours" class="btn btn-outline-navy btn-sm"><i class="fa-solid fa-compass"></i> Tours</a>
                    <a href="${pageContext.request.contextPath}/reservations" class="btn btn-outline-navy btn-sm"><i class="fa-solid fa-receipt"></i> Reservations</a>
                    <a href="${pageContext.request.contextPath}/admin/boats" class="btn btn-outline-navy btn-sm"><i class="fa-solid fa-sailboat"></i> Fleet</a>
                    <a href="${pageContext.request.contextPath}/admin/maintenance" class="btn btn-outline-navy btn-sm"><i class="fa-solid fa-screwdriver-wrench"></i> Maintenance</a>
                    <a href="${pageContext.request.contextPath}/safety-checks" class="btn btn-outline-navy btn-sm"><i class="fa-solid fa-clipboard-check"></i> Safety Checks</a>
                    <a href="${pageContext.request.contextPath}/admin/emergency" class="btn btn-outline-navy btn-sm"><i class="fa-solid fa-tower-broadcast"></i> Safety Alerts</a>
                    <a href="${pageContext.request.contextPath}/admin/promotions" class="btn btn-outline-navy btn-sm"><i class="fa-solid fa-tags"></i> Promotions</a>
                    <c:if test="${currentUser.role.admin}">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-gold btn-sm"><i class="fa-solid fa-users-gear"></i> Users</a>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Dual Column: Recent Bookings & Audit Trail -->
        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 30px;">
            <!-- Recent Reservations Table -->
            <div class="card">
                <div class="card-header">
                    <h3 style="font-size: 16px; margin: 0;"><i class="fa-solid fa-receipt"></i> Recent Customer Reservations</h3>
                    <a href="${pageContext.request.contextPath}/reservations" style="font-size: 13px; font-weight: 600;">View All</a>
                </div>
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Booking Ref</th>
                                <th>Guest</th>
                                <th>Tour</th>
                                <th>Amount</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="res" items="${recentBookings}">
                                <tr>
                                    <td><strong style="color: var(--marine-blue);">${res.bookingRef}</strong></td>
                                    <td>${res.customerName != null ? res.customerName : 'Guest'}</td>
                                    <td>${res.tourTitle}</td>
                                    <td><strong>${res.finalAmount.formatted}</strong></td>
                                    <td><span class="badge ${res.statusBadgeClass}">${res.statusLabel}</span></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Audit Trail Logs -->
            <div class="card">
                <div class="card-header">
                    <h3 style="font-size: 16px; margin: 0;"><i class="fa-solid fa-shield-halved"></i> Activity Audit Trail</h3>
                </div>
                <div class="card-body" style="padding: 16px;">
                    <ul style="list-style: none; font-size: 13px;">
                        <c:forEach var="log" items="${recentLogs}">
                            <li style="padding: 10px 0; border-bottom: 1px solid var(--border-color);">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
                                    <span class="badge badge-primary">${log.module}</span>
                                    <span style="font-size: 11px; color: var(--text-light);">${log.createdAt}</span>
                                </div>
                                <div style="color: var(--text-main);">${log.details}</div>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
