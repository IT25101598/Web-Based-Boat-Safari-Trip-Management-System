<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Promotion Redemption Analytics | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Coupon Redemptions & ROI Analytics</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Audit log of applied discount codes, guest savings, and reservation linkage.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/promotions" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-arrow-left"></i> Back to Promotion Campaigns
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <div class="card">
            <div class="card-header" style="background: var(--surface-card); border-bottom: 1px solid var(--border-color); padding: 18px 24px;">
                <h3 style="margin: 0; color: var(--navy-primary); font-size: 18px;">
                    <i class="fa-solid fa-receipt" style="color: var(--champagne-gold); margin-right: 8px;"></i>
                    Recorded Promo Redemptions
                </h3>
            </div>
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Redemption ID</th>
                            <th>Promo Code</th>
                            <th>Reservation ID</th>
                            <th>Guest Email</th>
                            <th>Discount Granted</th>
                            <th>Redemption Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty redemptions}">
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 40px; color: var(--text-light);">
                                        <i class="fa-solid fa-ticket-simple" style="font-size: 32px; margin-bottom: 12px; color: #CBD5E1; display: block;"></i>
                                        No promotional vouchers redeemed yet. Apply vouchers like <code>WHALE10</code>, <code>SAILFIXED</code>, or <code>MONSOON2026</code> in the booking wizard to test!
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="r" items="${redemptions}">
                                    <tr>
                                        <td>#${r.id}</td>
                                        <td>
                                            <span style="font-family: monospace; font-weight: 700; background: #FEF3C7; color: #92400E; padding: 3px 8px; border-radius: 4px;">
                                                ${r.promoCode}
                                            </span>
                                        </td>
                                        <td>
                                            <a href="${pageContext.request.contextPath}/reservations/view?id=${r.reservationId}" style="color: var(--navy-primary); font-weight: 600;">
                                                Booking #${r.reservationId}
                                            </a>
                                        </td>
                                        <td>${r.customerEmail != null ? r.customerEmail : 'Guest'}</td>
                                        <td><strong style="color: #059669;">- ${r.discountApplied.formatted}</strong></td>
                                        <td>${r.redeemedAt}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
