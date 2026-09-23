<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Boat & Fleet Management | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Boat & Fleet Management</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Catamarans, motor yachts, passenger capacity, and operational status control.</p>
        </div>
        <c:if test="${currentUser != null && currentUser.role.staff}">
            <a href="${pageContext.request.contextPath}/admin/boats/create" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-plus"></i> Register New Vessel
            </a>
        </c:if>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Vessel Name</th>
                            <th>Registration No</th>
                            <th>Vessel Type</th>
                            <th>Licensed Capacity</th>
                            <th>Engines</th>
                            <th>Cruising Speed</th>
                            <th>Operational Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="v" items="${vessels}">
                            <tr>
                                <td>
                                    <strong>${v.name}</strong>
                                    <div style="font-size: 12px; color: var(--text-muted);">${v.vesselArchitecture}</div>
                                </td>
                                <td><code>${v.registrationNo}</code></td>
                                <td><span class="badge badge-primary">${v.vesselType.displayName}</span></td>
                                <td>${v.capacity.maxPassengers} Guests (${v.capacity.cabins} Cabins)</td>
                                <td><span style="font-size: 13px;">${v.engines}</span></td>
                                <td>${v.cruisingSpeedKnots} Knots</td>
                                <td><span class="badge ${v.statusBadgeClass}">${v.statusLabel}</span></td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <c:if test="${currentUser != null && currentUser.role.staff}">
                                            <a href="${pageContext.request.contextPath}/admin/boats/edit?id=${v.id}" class="btn btn-outline-navy btn-sm" title="Edit Specs">
                                                <i class="fa-solid fa-pen"></i>
                                            </a>
                                            <!-- Status Toggle Form -->
                                            <form action="${pageContext.request.contextPath}/admin/boats/status" method="POST" style="display: inline;">
                                                <input type="hidden" name="csrf_token" value="${csrfToken}">
                                                <input type="hidden" name="id" value="${v.id}">
                                                <input type="hidden" name="status" value="${v.status.name() == 'AVAILABLE' ? 'UNDER_MAINTENANCE' : 'AVAILABLE'}">
                                                <input type="hidden" name="reason" value="Slipway inspection and maintenance">
                                                <button type="submit" class="btn btn-sm ${v.status.name() == 'AVAILABLE' ? 'btn-outline-gold' : 'btn-primary'}" title="Toggle Maintenance Mode">
                                                    <i class="fa-solid fa-arrows-rotate"></i>
                                                </button>
                                            </form>
                                            <!-- Delete Vessel Form -->
                                            <form action="${pageContext.request.contextPath}/admin/boats/delete" method="POST" onsubmit="return confirm('Permanently remove vessel ${v.name} from active fleet registry?');" style="display: inline;">
                                                <input type="hidden" name="csrf_token" value="${csrfToken}">
                                                <input type="hidden" name="id" value="${v.id}">
                                                <button type="submit" class="btn btn-outline-danger btn-sm" title="Delete Vessel">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </form>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty vessels}">
                            <tr>
                                <td colspan="8" style="text-align: center; padding: 48px 20px; color: var(--text-muted);">
                                    <i class="fa-solid fa-sailboat" style="font-size: 36px; color: #CBD5E1; margin-bottom: 12px; display: block;"></i>
                                    <span style="font-size: 15px; font-weight: 500;">No vessels found in active fleet registry.</span>
                                    <p style="margin-top: 6px; font-size: 13px; color: var(--text-light);">Click "Register New Vessel" above to add a new catamaran, yacht, or speedboat.</p>
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
