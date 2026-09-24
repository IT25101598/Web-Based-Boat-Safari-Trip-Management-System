<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Maintenance Management | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Boat Maintenance & Service Logs</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Slipway inspections, marine diesel overhauls, safety gear certification, and repair expenditure.</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <a href="${pageContext.request.contextPath}/admin/maintenance/reminders" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-bell"></i> Service Reminders
            </a>
            <a href="${pageContext.request.contextPath}/admin/maintenance/create" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-wrench"></i> Log Maintenance Job
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <!-- Maintenance Cost KPI -->
        <div class="card" style="margin-bottom: 24px; background: #F8FAFD; border: 1px solid var(--border-gold);">
            <div class="card-body" style="display: flex; justify-content: space-between; align-items: center; padding: 20px 24px;">
                <div>
                    <span style="font-size: 12px; font-weight: 700; text-transform: uppercase; color: var(--text-light);">Cumulative Fleet Service Expenditure</span>
                    <div style="font-size: 26px; font-weight: 800; color: var(--navy-primary); margin-top: 2px;">
                        LKR ${totalCost}
                    </div>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/maintenance/create" class="btn btn-primary btn-sm">
                        <i class="fa-solid fa-plus"></i> Record Repair Cost
                    </a>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Job ID</th>
                            <th>Vessel</th>
                            <th>Maintenance Classification</th>
                            <th>Scope / Description</th>
                            <th>Service Date</th>
                            <th>Cost</th>
                            <th>Service Provider / Surveyor</th>
                            <th>Status</th>
                            <th style="text-align: center;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${records}">
                            <tr>
                                <td>#${m.id}</td>
                                <td><strong>${m.vesselName != null ? m.vesselName : 'Vessel #'.concat(m.vesselId)}</strong></td>
                                <td><span class="badge badge-primary">${m.maintenanceType.title}</span></td>
                                <td>${m.description}</td>
                                <td>${m.scheduledDate}</td>
                                <td><strong>${m.cost.formatted}</strong></td>
                                <td>${m.serviceProvider != null ? m.serviceProvider : 'In-House Crew'}</td>
                                <td><span class="badge ${m.statusBadgeClass}">${m.statusLabel}</span></td>
                                <td>
                                    <div style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                                        <a href="${pageContext.request.contextPath}/admin/maintenance/edit?id=${m.id}" class="btn btn-outline-navy btn-sm" title="Update Maintenance Record">
                                            <i class="fa-solid fa-pen-to-square"></i> Update
                                        </a>
                                        <form action="${pageContext.request.contextPath}/admin/maintenance/delete" method="POST" style="display: inline; margin: 0;" onsubmit="return confirm('Are you sure you want to delete maintenance record #${m.id}?');">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                            <input type="hidden" name="id" value="${m.id}" />
                                            <button type="submit" class="btn btn-outline-danger btn-sm" title="Delete Maintenance Record">
                                                <i class="fa-solid fa-trash"></i> Delete
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty records}">
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 48px 20px; color: var(--text-muted);">
                                    <i class="fa-solid fa-wrench" style="font-size: 36px; color: #CBD5E1; margin-bottom: 12px; display: block;"></i>
                                    <span style="font-size: 15px; font-weight: 500;">No maintenance logs recorded.</span>
                                    <p style="margin-top: 6px; font-size: 13px; color: var(--text-light);">Click "+ Record Repair Cost" to log a new service or repair.</p>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
