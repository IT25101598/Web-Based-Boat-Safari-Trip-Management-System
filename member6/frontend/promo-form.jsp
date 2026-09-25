<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${promotion != null && promotion.id > 0}" />
<c:set var="pageTitle" value="${isEdit ? 'Edit Promotion' : 'Create Promotion'} | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">${isEdit ? 'Modify Promotion Campaign' : 'Create Promotion Campaign'}</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Configure dynamic discount strategies, promo codes, minimum spend thresholds, and redemption limits.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/promotions" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-arrow-left"></i> Back to Promotions
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 800px;">
        <div class="card">
            <div class="card-header" style="background: var(--surface-card); border-bottom: 1px solid var(--border-color); padding: 20px 24px;">
                <h3 style="margin: 0; color: var(--navy-primary); font-size: 20px;">
                    <i class="fa-solid fa-tag" style="color: var(--champagne-gold); margin-right: 8px;"></i>
                    Campaign Details & Discount Algorithms
                </h3>
            </div>
            <div class="card-body" style="padding: 24px;">
                <form action="${pageContext.request.contextPath}/admin/promotions" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}" />
                    <input type="hidden" name="id" value="${promotion.id}" />

                    <div class="grid grid-2" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label" for="name">Campaign Name <span style="color: #EF4444;">*</span></label>
                            <input type="text" name="name" id="name" class="form-control" value="${promotion.name}" placeholder="e.g., Mirissa Whale Season Special" required />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="promoCode">Promotional Voucher Code <span style="color: #EF4444;">*</span></label>
                            <input type="text" name="promoCode" id="promoCode" class="form-control" value="${promotion.promoCode}" placeholder="e.g., WHALE20" style="text-transform: uppercase;" required />
                        </div>
                    </div>

                    <div class="grid grid-2" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label" for="discountType">Discount Strategy <span style="color: #EF4444;">*</span></label>
                            <select name="discountType" id="discountType" class="form-control" required>
                                <c:forEach var="dt" items="${discountTypes}">
                                    <option value="${dt.name()}" ${promotion.discountType == dt ? 'selected' : ''}>${dt.displayName}</option>
                                </c:forEach>
                            </select>
                            <div style="font-size: 12px; color: var(--text-light); margin-top: 4px;">
                                Implements the Strategy Pattern in OOP.
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="discountValue">Discount Value (% or LKR) <span style="color: #EF4444;">*</span></label>
                            <input type="number" step="0.01" min="0" name="discountValue" id="discountValue" class="form-control" value="${promotion.discountValue}" required />
                        </div>
                    </div>

                    <div class="grid grid-3" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label" for="minSpend">Minimum Booking Amount (LKR)</label>
                            <input type="number" step="0.01" min="0" name="minSpend" id="minSpend" class="form-control" value="${promotion.minSpend}" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="maxDiscount">Maximum Discount Cap (LKR)</label>
                            <input type="number" step="0.01" min="0" name="maxDiscount" id="maxDiscount" class="form-control" value="${promotion.maxDiscount}" placeholder="0 for no cap" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="maxRedemptions">Max Usage Limit <span style="color: #EF4444;">*</span></label>
                            <input type="number" min="1" name="maxRedemptions" id="maxRedemptions" class="form-control" value="${promotion.maxRedemptions > 0 ? promotion.maxRedemptions : 100}" required />
                        </div>
                    </div>

                    <div class="grid grid-2" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label" for="startDate">Valid From Date <span style="color: #EF4444;">*</span></label>
                            <input type="date" name="startDate" id="startDate" class="form-control" value="${promotion.startDate}" required />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="endDate">Valid Until Date <span style="color: #EF4444;">*</span></label>
                            <input type="date" name="endDate" id="endDate" class="form-control" value="${promotion.endDate}" required />
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 24px;">
                        <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; font-weight: 600; color: var(--navy-primary);">
                            <input type="checkbox" name="active" value="true" ${promotion.active || !isEdit ? 'checked' : ''} />
                            Enable and Activate Campaign Immediately
                        </label>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid var(--border-color); padding-top: 20px;">
                        <a href="${pageContext.request.contextPath}/admin/promotions" class="btn btn-outline-secondary">Cancel</a>
                        <button type="submit" class="btn btn-gold">
                            <i class="fa-solid fa-floppy-disk"></i> ${isEdit ? 'Update Promotion' : 'Publish Promotion'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
