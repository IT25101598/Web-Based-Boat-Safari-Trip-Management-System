<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Promotion & Discount Strategy | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Promotional Campaigns & Discount Strategy</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Dynamic discount algorithms (Percentage, Fixed Value, Monsoon Off-Peak Seasonal Strategy) & coupon redemptions.</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <a href="${pageContext.request.contextPath}/admin/promotions/redemptions" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-chart-line"></i> Redemption Analytics
            </a>
            <a href="${pageContext.request.contextPath}/admin/promotions/create" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-tags"></i> Create Promotion Campaign
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">

        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Campaign Name</th>
                            <th>Promo Code</th>
                            <th>Strategy Type</th>
                            <th>Discount Benefit</th>
                            <th>Minimum Spend</th>
                            <th>Validity Period</th>
                            <th>Usage / Cap</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${promotions}">
                            <tr>
                                <td>#${p.id}</td>
                                <td><strong>${p.name}</strong></td>
                                <td>
                                    <span style="font-family: monospace; font-weight: 700; background: #FEF3C7; color: #92400E; padding: 4px 8px; border-radius: 4px; letter-spacing: 1px;">
                                        ${p.promoCode}
                                    </span>
                                </td>
                                <td><span class="badge badge-primary">${p.discountType.displayName}</span></td>
                                <td><strong>${p.discountSummary}</strong></td>
                                <td>LKR ${p.minSpend}</td>
                                <td>
                                    <div style="font-size: 12px; color: var(--text-light);">
                                        ${p.startDate} to ${p.endDate}
                                    </div>
                                </td>
                                <td>
                                    <div style="font-size: 13px; font-weight: 600;">
                                        ${p.currentRedemptions} / ${p.maxRedemptions}
                                    </div>
                                    <div style="width: 100%; background: #E2E8F0; height: 6px; border-radius: 3px; margin-top: 4px; overflow: hidden;">
                                        <div style="width: ${(p.currentRedemptions * 100) / (p.maxRedemptions > 0 ? p.maxRedemptions : 1)}%; background: var(--champagne-gold); height: 100%;"></div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge ${p.active ? 'badge-success' : 'badge-danger'}">
                                        ${p.active ? 'ACTIVE' : 'INACTIVE'}
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/admin/promotions/edit?id=${p.id}" class="btn btn-outline-secondary btn-xs" title="Edit Campaign">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </a>
                                        <form action="${pageContext.request.contextPath}/admin/promotions/delete" method="POST" style="display: inline;" onsubmit="return confirm('Delete this promotion?');">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                            <input type="hidden" name="id" value="${p.id}" />
                                            <button type="submit" class="btn btn-outline-danger btn-xs" title="Delete">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </form>
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
